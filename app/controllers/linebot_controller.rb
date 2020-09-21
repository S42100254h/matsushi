class LinebotController < ApplicationController
  require 'line/bot'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
        # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          explain = "数字を選択してください\n\n↓↓↓↓↓\n1. 「来月の20日予定ある？」\n2. 「あ、はるにゃんだ！！」\n3. 「あ、島田だ！！」\n4. 「松下くんかっこいい！」"

          case input
          when "1"
            push = "ごめん。\nその日家族と定山渓行くから無理。"
          when "2"
            push = "はるにゃん！！ぐふふ。ごちです。"
          when "3"
            push = "は？野郎になんて興味ねーよ。リア充爆発しろ！"
          when "4"
            push = "ぐふ。べ、べつに嬉しくなんてないんだからね！ぐふ。"
          else
            push = "説明をちゃんと読んでください。数字を選んでって言ってるじゃないですか。\nアラサーになってまで何やってんの？"
          end
        end

        message = [{ type: 'text', text: push }, { type: 'text', text: explain }]
        
        client.reply_message(event['replyToken'], message)
        
      # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)

      # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
