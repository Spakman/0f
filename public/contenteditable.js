window.onload = function() {
  let article = new Article(document.getElementById("editableArticle"));
  new EditMenu(document.getElementById("editMenu"), document.getElementById("hideMenu"), article);
};


class EditMenu {
  constructor(element, closeMenuElement, article) {
    this.element = element;
    this.closeMenuElement = closeMenuElement;
    this.article = article;
    this.hide();
    this.listenToArticleEditingState();
    this.setupCloseMenuElement();
  }

  show() {
    this.element.classList.remove("hidden");
  }

  hide() {
    this.element.classList.add("hidden");
  }

  listenToArticleEditingState() {
    this.article.element.addEventListener("click", function(ev) {
      this.show();
    }.bind(this));

    this.article.element.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        this.hide();
      }
    }.bind(this));
  }

  setupCloseMenuElement() {
    this.closeMenuElement.addEventListener("click", function(ev) {
      this.hide();
      this.article.stopEditing();
      ev.stopPropagation()
    }.bind(this));
  }
}


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
        this.stopEditing();
      }
    }.bind(this));

    this.element.addEventListener("input", this.save.bind(this));
  }

  save() {
    this.pageSaver.save(this.element.innerHTML);
  }

  createAnchorsFromLinks() {
    this.element.innerHTML =
      this.element.innerHTML.replace(
        /(?:http([s]?):\/\/)?(([0-9a-zA-Z-_]+[.])+[0-9a-zA-Z-_]+(\/[0-9a-zA-Z-_]*)*(\?[^\s]*)*)(?![^\s<]*>)/gi,
        '<a href="http$1://$2">$2</a>'
      );
  }

  stopEditing() {
    this.element.contentEditable = false;
    this.createAnchorsFromLinks();
    this.ensureLinksAreClickable();
    this.save();
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
