require "lita"

module Lita
  module Handlers
    class MeetupRsvps < Handler
    end

    # How often we should poll for new events/meetups from your groups.
    config :events_poll_interval, type: Integer, default: 3600

    # Configure the Meetup you want to poll and the channel you want it to
    # output it in.
    config :events, type: Hash, required: true

    # * Poll for new events
    # * Compare the events received with the ones stored in redis
    # * Send triggers for the events which weren't in redis
    # * In the trigger do
    # ** Send trigger for rsvps
    # ** Send trigger for event_comments
    # ** Save the current event in redis
    #
    # http://www.meetup.com/meetup_api/docs/2/events/
    # https://api.meetup.com/2/events?group_urlname=STHLM-Lounge-Hackers&page=20&key=7714627f7e7d61275a161303b3e3332
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

    Lita.register_handler(MeetupRsvps)
  end
end
