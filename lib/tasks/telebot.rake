namespace :telebot do
  desc "TODO"
  task parse: :environment do
    Article.parse_by_filters("http://neagent.by/board/minsk/?catid=1&order=postdate_za")
  end

  desc "TODO"
  task send: :environment do
    Article.parse_not_parsed
    articles = Article.prepare_to_send
    sent_api_ids = TelegrammNotifier.send_article_messages(articles)
    Article.bulk_update_as_sent(sent_api_ids)
  end

  desc "TODO"
  task clean: :environment do
    Article.clean
  end

end
