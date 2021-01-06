require 'json'
require 'date'
require 'uri'
require 'slack-notifier'
require './lib/backlog_controller'

## Slack 通知文言テンプレ
WEEKLY_REMINDER_TEXT = <<TEXT
##ISSUE_MENTION##
今週期限の課題は下記の通りです。（計##ISSUE_COUNT##件）
##ISSUE_URL##
自信が担当の課題、及びお客様にリマインドが必要な課題の確認お願いします :pray:
TEXT

## Backlog 検索時条件
## 使えるパラメータは https://developer.nulab.com/ja/docs/backlog/api/2/get-issue-list/#
BACKLOG_CONDITION = {
  statusId: [1, 2, 3],
  dueDateUntil: 'yyyy-MM-dd'
}
## 検索用URL
BACKLOG_URL = '##BASE_URL##/find?projectId=##BACKLOG_PROJ_ID##&statusId=1&statusId=2&statusId=3&sort=LIMIT_DATE&limitDateRange.end=##DUE_DATE##'

## Lambda の開始関数
def lambda_handler(event:, context:)
  begin
    $is_debug = false

    # Set Backlog search condition
    due_date = Date.today + 3
    cond = BACKLOG_CONDITION
    cond[:dueDateUntil] = due_date.strftime('%Y-%m-%d')
    # Get Matching Issues from Backlog
    backlog_controller = BacklogController.new(ENV['BACKLOG_SPACE_ID'], ENV['BACKLOG_API_KEY'])
    issues = backlog_controller.list_matching_issues(ENV['BACKLOG_PROJ_ID'], cond)

    # Slack Message 内のURL生成
    issue_url = BACKLOG_URL
    issue_url = issue_url.gsub('##BASE_URL##', backlog_controller.base_url)
    issue_url = issue_url.gsub('##BACKLOG_PROJ_ID##', ENV['BACKLOG_PROJ_ID'])
    issue_url = issue_url.gsub('##DUE_DATE##', URI.encode_www_form_component(due_date.strftime('%Y/%m/%d')))
    # Slack Message の生成
    msg = WEEKLY_REMINDER_TEXT
    msg = msg.gsub('##ISSUE_MENTION##', ENV['MESSAGE_MENTION'])
    msg = msg.gsub('##ISSUE_COUNT##', issues.size.to_s)
    msg = msg.gsub('##ISSUE_URL##', issue_url)
    send_slack_msg(msg)
  rescue => err
    # rescues all service API errors
    puts err
    send_slack_msg msg: err
  end
end

## Send Slack Message Using slack-notifier Gem
def send_slack_msg(msg, attachments=nil)
  begin
    # Create Slack notifier
    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'] do
      defaults channel: ENV['SLACK_CHANNEL'], username: ENV['SLACK_USERNAME']
    end

    # 投稿するメッセージ内容。
    if $is_debug
      puts msg.to_s
    elsif !attachments.nil?
      notifier.post icon_emoji: ENV['SLACK_ICON_EMOJI'], text: msg, attachments: attachments
    else
      notifier.post icon_emoji: ENV['SLACK_ICON_EMOJI'], text: msg
    end
  rescue => err
    # rescues all service API errors
    puts err
  end
end
