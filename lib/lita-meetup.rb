require "lita"
require 'json'

module Lita
  module Handlers
    class Meetup < Handler

      # How often we should poll for new events/meetups from your groups.
      config :events_poll_interval, type: Integer, default: 3600

      # Configure the Meetup you want to poll and the channel you want it to
      # output it in.
      config :events, type: Hash, required: true

      # Your Meetup API key
      # output it in.
      config :api_key, type: String, required: true

      # FIXME How does this work with reconnection? Remove the timer on
      # disconnect?
      on :connected, :poll_for_new_events
      on :shut_down_started, :unsubscribe_to_all_events
      route(/a/, :find_new_events)

      on :meetup_subscribe_events, :meetup_subscribe_events
      on :meetup_subscribe_rsvps, :meetup_subscribe_rsvps
      on :meetup_subscribe_comments, :meetup_subscribe_comments

      def poll_for_new_events(payload)
        unsubscribe_to_all_events payload
        find_new_events payload
      end

      def find_new_events(payload)
        config.events.each do |room, meetups|
          log.debug "Finding new events for room '#{room}' on meetups: #{meetups}"
          meetups.each do |meetup|
            events = get_current_events_for meetup

            events.select! { |event| event["status"] == "upcoming" }

            events.each do |event|
              # If event_id isn't already subscribed to, do it.
              if ! redis.sismember(room, event["id"])
                robot.trigger(:meetup_subscribe_events, event_id: event["id"], room: room)
              end
            end
          end
        end
      end

      def unsubscribe_to_all_events(payload)
        log.info "Unsubscribing from all events"
        config.events.each do |room, meetups|
          log.debug "Deleting events for room '#{room}'"
          redis.del payload[:room]
        end
      end

      def meetup_subscribe_events(payload)
        log.info "Subscribing to event #{payload[:event_id]} for #{payload[:room]}"
        robot.trigger(:meetup_subscribe_rsvps, event_id: payload[:event_id], room: payload[:room])
        robot.trigger(:meetup_subscribe_comments, event_id: payload[:event_id], room: payload[:room])
        redis.sadd payload[:room], payload[:event_id]
      end

      def meetup_subscribe_rsvps(payload)
        log.debug "Subscribing to RSVPs on event #{payload[:event_id]} for #{payload[:room]}"
      end

      def meetup_subscribe_comments(payload)
        log.debug "Subscribing to comments on event #{payload[:event_id]} for #{payload[:room]}"
      end

      def get_current_events_for(meetup)
        JSON.parse(
          http.get(
            "https://api.meetup.com/2/events?group_urlname=#{meetup}&page=20&key=#{config.api_key}"
          ).body
        )["results"]
      end

      # * Poll for new events
      # * Compare the events received with the ones stored in redis
      # * Send triggers for the events which weren't in redis
      # * In the trigger do
      # ** Send trigger for rsvps
      # ** Send trigger for event_comments
      # ** Save the current event in redis
      #
      # http://www.meetup.com/meetup_api/docs/2/events/
      # https://api.meetup.com/2/events?group_urlname=STHLM-Lounge-Hackers&page=20&key=#{config.api_key}
      #
      # http://www.meetup.com/meetup_api/docs/stream/2/rsvps/#http
      # http://stream.meetup.com/2/rsvps?event_id=XXX&since_mtime=restart_from
      #
      # http://www.meetup.com/meetup_api/docs/stream/2/event_comments/#http
      # http://stream.meetup.com/2/event_comments?event_id=XXX&since_mtime=restart_from
      #
      # every 60 robot.trigger :check_alive, :room: room, :meetup-url: "sthlm-lounge-hackers"
      # check_alive
      #   redis-lock || return
      #   Net::HTTP payload[:meedup-url] do
      #     robot.send_message payload[:room] MEOW
      #   end
      # end
    end

    Lita.register_handler(Meetup)
  end
end
