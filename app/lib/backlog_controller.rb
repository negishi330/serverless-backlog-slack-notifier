#!/usr/bin/env ruby -
# coding: utf-8
require 'rest-client'

class BacklogController
  @base_url = nil
  @api_key = nil

  ## Backlog URLの返却 
  def base_url
    return @base_url
  end

  # BacklogKitモジュールのClientクラスのnewメソッドで@clientインスタンスを生成
  # getWikiで使用するためインスタンス変数として定義
  def initialize(space_id, api_key)
    @base_url = "https://#{space_id}.backlog.jp"
    @api_key = api_key
  end

  # Issue の詳細情報取得
  def get_issue(issueId)
    response = RestClient.get(
      "#{@base_url}/api/v2/issues/#{issueId}",
      {params: {apiKey: @api_key}})
    return JSON.parse(response.body)
  end

  # 最近の更新の取得
  def list_recent_updated_issues(prjId)
    tmp_results = []
    response = RestClient.get(
      "#{@base_url}/api/v2/space/activities",
      {params: {apiKey: @api_key, activityTypeId: [1,2,3]}})
    JSON.parse(response.body).each do |update|
      tmp_results.push update if update['project']['id'].to_s == prjId
    end
    puts "RECENT UPDATE COUNT: #{tmp_results.size.to_s}\n"
    return tmp_results
  end

  # 検索条件に一致する課題の一覧取得
  def list_matching_issues(prjId, searchCond)
    tmp_results = []
    puts "SEARCH CONDITION: #{searchCond.merge({apiKey: @api_key, projectId: [prjId], count: 100 })}\n"
    response = RestClient.get(
      "#{@base_url}/api/v2/issues",
      {params: searchCond.merge({apiKey: @api_key, projectId: [prjId], count: 100 })})
    tmp_results = JSON.parse(response.body)
    puts "RECENT UPDATE COUNT: #{tmp_results.size.to_s}\n"
    return tmp_results
  end
end
