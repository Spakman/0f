window.onload = function() {
  let pageSaver = new PageSaver();

  document.querySelectorAll("[contenteditable]").forEach(function(element) {
    element.addEventListener("input", function(e) {
      pageSaver.save(e.target.innerHTML);
    });
  });
};

class PageSaver {
  constructor() {
    this.saveToServerAfter = 1;
    this.saveCount = 0;
  }

  save(content) {
    this.saveCount++;
    if(this.saveCount >= this.saveToServerAfter) {
      this.performSave(content).then(aftersave(response).bind(this));
    }
  }

  performSave(content) {
    return fetch(document.URL, {
      method: "post",
      body: content
    }).catch(function(err) {
      console.error(err);
    });
  }

  afterSave(response) {
    if(response.ok) {
      this.saveCount = 0;
      return;
    }
    throw new Error("Save failed.");
  }
}
