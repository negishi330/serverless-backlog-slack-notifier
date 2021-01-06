# serverless-projects

projects created using serverless framework in ruby 2.7

# commands

- 環境の構築
  - docker のイメージ作成
    `docker-compose build serverless`
  - （新規の場合）新規プロジェクト用コマンド
    `docker-compose run --rm serverless sls create -t aws-ruby`
  - Gem の取得
    `docker-compose run --rm serverless bundle install --path vendor/bundle`
  - AWS 環境へ反映（環境変数を設定して deploy する）
    `cp .env.tmpl .env`
    `vi .env`
    `docker-compose run --rm serverless sls deploy`
  - Local 環境上での実行
    `docker-compose run --rm serverless sls invoke local -f func -d '{"key":"value"}'`
  - AWS 環境上での実行
    `docker-compose run --rm serverless sls invoke -f func -d '{"key":"value"}'`
  - AWS 環境から削除
    `docker-compose run --rm serverless sls remove`
