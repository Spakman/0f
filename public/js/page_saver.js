class PageSaver {
  constructor(callbacks) {
    this.callbacks = callbacks;
    this.saveToServerAfter = 1;
    this.saveCount = 0;
  }

  save(article) {
    this.saveCount++;
    if(this.saveCount >= this.saveToServerAfter) {
      this.performSave(article).then(this.afterSave.bind(this, article));
    }
  }

  performSave(article) {
    let headers = {};
    if(article.dataset.newPage !== undefined) {
      headers["X-ZEROEFF-NEW-PAGE"] = "true";
    }
    return fetch(document.URL, {
      method: "put",
      body: article.innerHTML,
      headers: headers,
      credentials: "include"
    }).catch(function(err) {
      this.callbacks.failure();
      console.error(err);
    }.bind(this));
  }

  afterSave(article, response) {
    if(response.ok) {
      this.saveCount = 0;
      this.callbacks.success();
      article.removeAttribute("data-new-page");
    }
  }
}
