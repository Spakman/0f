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
    this.element.addEventListener("click", function(ev) {
      this.contentEditable = true;
      this.focus();
    });

    this.element.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        ev.target.contentEditable = false;
        this.ensureLinksAreClickable();
      }
    }.bind(this));

    this.element.addEventListener("input", function(ev) {
      this.pageSaver.save(ev.target.innerHTML);
    }.bind(this));
  }

  stopPropagation(ev) {
    ev.stopPropagation();
  }
}


class PageSaver {
  constructor() {
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
