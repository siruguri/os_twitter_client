$(document).ready ->
  if $('#article-id-tag').val()
    article_id = $('#article-id-tag').val().trim()
    var_dummy = 1
    api_path = Routes.readability_tag_words_path() + '?id=' + article_id
    $("#tags-list").tokenInput(api_path,
      {hintText: '', insertionPoint: 'after', preventDuplicates: true, selectFirst: false})
  null

  $("#tags-list-submit").click (evt) ->
    option_list = $('.token-input-token p').map ->
      return $(this).text()
    .get().join(',')
    $('input#token-list').val option_list
    $('#tags-form').submit()
      
