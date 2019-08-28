window.PostView = Backbone.View.extend
  el: "body"
  events:
    "click .editor-toolbar .edit a": "toggleEditView"
    "click .editor-toolbar .preview a": "togglePreviewView"

  initialize: (opts) ->
    $("<div id='preview' class='markdown form-control' style='display:none;'></div>").insertAfter( $('#post_body') )
    window._editor = new Editor()
    title = $('#post-detail > div > h1').text()
    $('title').text(title)
    $("meta[property='og:title']").attr('content', title);
    summary = $('#post_summary').text()
    $("meta[name='description']").attr('content', summary);
    $("meta[property='og:description']").attr('content', summary);

  toggleEditView: (e) ->
    $(e.target).parent().addClass('active')
    $('.preview a').parent().removeClass('active')
    $('#preview').hide()
    $('#post_body').show()
    false

  togglePreviewView: (e) ->
    $(e.target).parent().addClass('active')
    $('.edit a').parent().removeClass('active')
    $('#preview').html('Loading...')
    $('#post_body').hide()
    $('#preview').show()
    $.post '/posts/preview', {body: $('#post_body').val()}, (data)->
      $('#preview').html(data)
      false
    false
  
  uploadFile: (item, filename) ->
    self = @
    formData = new FormData()
    formData.append "file", item, filename
    $.ajax
      url: '/photos'
      type: "POST"
      data: formData
      dataType: "JSON"
      processData: false
      contentType: false
      beforeSend: ->
        self.showUploading()
      success: (e, status, res) ->
        self.appendImageFromUpload([res.responseJSON.url])
        self.restoreUploaderStatus()
      error: (res) ->
        App.alert("上传失败")
        self.restoreUploaderStatus()
      complete: ->
        self.restoreUploaderStatus()

document.addEventListener 'turbolinks:load',  ->
  window._postView = new PostView()
