class ScheduleController < ApplicationController
  CHANNEL_ACCESS_TOKEN = "mNyKmuKApOfHKjaO9volAERXIemXAVGeXcfMGmxjR+Ljr82yKq4Tnoz7QRSINiSmqQufvY3w1eG1VvKOZVR9tdLJqbU8v+i0gSFWlTlEu873kmyQ4QhWhEJuf6QSHis8dgDv71nZvJawQHChapFobAdB04t89/1O/w1cDnyilFU="
	CHANNEL_SECRET = "3a25e3b7b0a94944c403b7c5dbea1236"
  USER_ID = "Ube149c0420283a0d0e7ccd5a6794c9e7"

  def index
    uri = URI('https://spla3.yuu26.com/api/bankara-open/schedule')
    #httpステータスを確認し200以外はリターンする
    return unless Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)

    response = Net::HTTP.get(uri)
    @schedule = JSON.parse(response)
    send_line_message
  end

  private

  def send_line_message
    # メッセージの整形
    message = "Splatoon 3のスケジュール情報\n"
    @schedule["results"].each do |res|
      start_time = Time.parse(res["start_time"]).strftime("%H:%M")
      end_time = Time.parse(res["end_time"]).strftime("%H:%M")

      if start_time == "19:00" || start_time == "21:00" 
        message += "#{start_time}~#{end_time}\n"
        message += "#{res["rule"]["name"]}\n"
        res["stages"].each do |stage|
          message += "┗#{stage["name"]}\n"
        end
        message += "\n"
      end
    end

    client = Line::Bot::Client.new { |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_ACCESS_TOKEN
    }

    message = {
      type: 'text',
      text: message
    }

    client.push_message(USER_ID, message)
  end
end
