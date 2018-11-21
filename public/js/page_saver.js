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
      console.error(err);
    });
  }

  afterSave(response) {
    if(response.ok) {
      this.saveCount = 0;
      this.callbacks.success();
      return;
    }
    else {
      this.callbacks.failure();
      return;
    }
  }
}
