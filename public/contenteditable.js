window.onload = function() {
  new Article(document.getElementById("editableArticle"));
};


class Article {
  constructor(element) {
    this.element = element;
    this.pageSaver = new PageSaver();
    this.ensureLinksAreClickable();
    this.makeElementEditable();
  }

  ensureLinksAreClickable() {
    Array.from(this.element.getElementsByTagName("a")).forEach(function(a) {
      a.removeEventListener("click", this.stopPropagation);
      a.addEventListener("click", this.stopPropagation);
    }.bind(this));
  }

  makeElementEditable() {
    this.element.addEventListener("click", this.startEditing.bind(this));
    this.element.addEventListener("input", function() {
      this.save();
    }.bind(this));

    this.element.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        this.stopEditing();
      }
    }.bind(this));
  }

  startEditing() {
    this.element.contentEditable = true;
    this.element.focus();
  }

  stopEditing() {
    this.element.contentEditable = false;
    this.ensureLinksAreClickable();
    this.save({ force: true });
  }

  save(options = { force: false }) {
    this.pageSaver.save(this.element.innerHTML, options);
  }

  stopPropagation(ev) {
    ev.stopPropagation();
  }
}


class PageSaver {
  constructor() {
    this.saveToServerAfter = 10;
    this.saveCount = 0;
  }

  save(content, options = { force: false }) {
    this.saveCount++;
    if(this.saveCount >= this.saveToServerAfter || options.force) {
      this.performSave(content).then(this.afterSave.bind(this));
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
