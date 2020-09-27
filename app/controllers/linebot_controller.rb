class LinebotController < ApplicationController
  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
        # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          explain = "数字を選択してください\n\n↓↓↓↓↓\n1. 「TVで恋愛ものとか見てんでしょ？」\n2. 「家に遊びに行ってもいい？」\n3. 「あ、島田だ！！」\n4. 「最近太った？」\n5. 「今日雨降るか教えて」"

          case input
          when "1"
            push = ["いやぁ、徳井消えてからテラハも見なくなったわー", "み、みてるわけないだろ（でゅふ）", "そんなじゃもう楽しめない大人な男になったわー", "バチェラー見てないの？人生のバイブルでしょ。"].sample
          when "2"
            push = ["女の子居るから無理だわー。\nおい、オレが滑ったみたいになったじゃねぇか！", "ごめん。\nその日家族と定山渓に行ってるから無理だわー。"].sample
          when "3"
            push = ["は？野郎になんて興味ねーよ。リア充爆発しろ！", "あ？うん。"].sample
          when "4"
            push = ["うるせぇ、お前らの本名をネットの海に晒すぞ！笑", "幸せ太りだわ（どや）", "いやいや、岡部さんの方が太ったでしょ笑"].sample
          when "5"
            push = "今どこに住んでるか教えて！\n「東京」、「千葉」、「札幌」、「苫小牧」、「愛知」"
          when /.*(東京|とうきょう).*/
            url  = "https://www.drk7.jp/weather/xml/13.xml"
            xml  = open( url ).read.toutf8
            doc = REXML::Document.new(xml)
            xpath = 'weatherforecast/pref/area[4]/'

            min_per = 20
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =　"今日は雨が降りそうだから傘があった方が良いよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
            else
              push = "今日は雨は降らなさそうだよ。今日も一日頑張るだにゃん！！"
            end
          when /.*(千葉|ちば).*/
            url  = "https://www.drk7.jp/weather/xml/12.xml"
            xml  = open( url ).read.toutf8
            doc = REXML::Document.new(xml)
            xpath = 'weatherforecast/pref/area[2]/'

            min_per = 20
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =　"今日は雨が降りそうだから傘があった方が良いよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
            else
              push = "今日は雨は降らなさそうだよ。今日も一日頑張るだにゃん！！"
            end
          when /.*(札幌|さっぽろ).*/
            url  = "https://www.drk7.jp/weather/xml/01.xml"
            xml  = open( url ).read.toutf8
            doc = REXML::Document.new(xml)
            xpath = 'weatherforecast/pref/area[11]/'

            min_per = 20
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =　"今日は雨が降りそうだから傘があった方が良いよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
            else
              push = "今日は雨は降らなさそうだよ。今日も一日頑張るだにゃん！！"
            end
          when /.*(岩見沢|いわみざわ).*/
            url  = "https://www.drk7.jp/weather/xml/01.xml"
            xml  = open( url ).read.toutf8
            doc = REXML::Document.new(xml)
            xpath = 'weatherforecast/pref/area[15]/'

            min_per = 20
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =　"今日は雨が降りそうだから傘があった方が良いよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
            else
              push = "今日は雨は降らなさそうだよ。今日も一日頑張るだにゃん！！"
            end
          when /.*(愛知|あいち).*/
            url  = "https://www.drk7.jp/weather/xml/23.xml"
            xml  = open( url ).read.toutf8
            doc = REXML::Document.new(xml)
            xpath = 'weatherforecast/pref/area[1]/'

            min_per = 20
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =　"今日は雨が降りそうだから傘があった方が良いよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
            else
              pus
          else
            push = "説明をちゃんと読めよ。数字を選んでって言ってるじゃん。\nアラサーになってまで何やってんの？"
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
    end
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
