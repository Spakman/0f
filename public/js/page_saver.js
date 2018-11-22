class PageSaver {
  constructor(callbacks) {
    this.callbacks = callbacks;
    this.saveToServerAfter = 1;
    this.saveCount = 0;
  }

  save(content) {
    this.saveCount++;
    if(this.saveCount >= this.saveToServerAfter) {
      this.performSave(content).then(this.afterSave.bind(this));
    }
  }

  performSave(content) {
    return fetch(document.URL, {
      method: "put",
      body: content,
      credentials: "include"
    }).catch(function(err) {
      this.callbacks.failure();
      console.error(err);
    }.bind(this));
  }

  afterSave(response) {
    if(response.ok) {
      this.saveCount = 0;
      this.callbacks.success();
    }
  }
}
