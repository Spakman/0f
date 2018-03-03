window.onload = function() {
  let article = new Article(document.getElementById("editableArticle"));
  let createLink = new CreateLink(document.getElementById("createLinkForm"), document.getElementById("createLinkHref"), document.getElementById("createLinkButton"), article);
  new EditMenu(document.getElementById("editMenu"), document.getElementById("hideMenu"), document.getElementById("createLink"), article, createLink);
};


class EditMenu {
  constructor(element, closeMenuElement, linkMenuElement, article, createLink) {
    this.element = element;
    this.closeMenuElement = closeMenuElement;
    this.linkMenuElement = linkMenuElement;
    this.article = article;
    this.hide();
    this.listenToArticleEditingState();
    this.setupCloseMenuElement();
    this.createLink = createLink;
    this.setupLinkMenuElement();
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
      ev.preventDefault();
      ev.stopPropagation();
      this.hide();
      this.createLink.hide();
      this.article.stopEditing();
    }.bind(this));
  }

  setupLinkMenuElement() {
    this.linkMenuElement.addEventListener("click", function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      this.createLink.toggle();
    }.bind(this));
  }
}


class CreateLink {
  constructor(formElement, hrefElement, buttonElement, article) {
    this.formElement = formElement;
    this.hrefElement = hrefElement;
    this.buttonElement = buttonElement;
    this.article = article;
    this.onlyAllowButtonPressWhenHrefIsNotEmpty();
    this.setupCreateLinkButton();
    this.selectionToLink = null;
  }

  onlyAllowButtonPressWhenHrefIsNotEmpty() {
    this.hrefElement.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        this.hide();
        return;
      }
      if(this.hrefElement.value.length > 0) {
        this.buttonElement.disabled = false;
      }
      else {
        this.buttonElement.disabled = true;
      }
    }.bind(this));
  }

  saveSelection() {
    var sel = window.getSelection();
    if(sel.getRangeAt && sel.rangeCount) {
      var ranges = [];
      for(var i = 0, len = sel.rangeCount; i < len; ++i) {
        ranges.push(sel.getRangeAt(i));
      }
      return ranges;
    }
    return null;
  }

  restoreSelection(savedSel) {
    var sel = window.getSelection();
    sel.removeAllRanges();
    for(var i = 0, len = savedSel.length; i < len; ++i) {
      sel.addRange(savedSel[i]);
    }
  }

  toggle() {
    if(this.selectionToLink) {
      this.hide();
    }
    else {
      this.display();
    }
  }

  display() {
    this.selectionToLink = this.saveSelection();
    this.formElement.classList.remove("hidden");
    this.hrefElement.focus();
  }

  hide() {
    this.restoreSelection(this.selectionToLink);
    this.formElement.classList.add("hidden");
    this.selectionToLink = null;
    this.hrefElement.value = "";
    this.article.focus();
  }

  createLink() {
    if(this.selectionToLink) {
      this.restoreSelection(this.selectionToLink);
      document.execCommand('createLink', false, this.hrefElement.value);
      this.hide();
    }
  }

  setupCreateLinkButton() {
    this.buttonElement.addEventListener("click", function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      this.createLink();
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

  focus() {
    this.element.focus();
  }

  save() {
    this.pageSaver.save(this.element.innerHTML);
  }

  stopEditing() {
    this.element.contentEditable = false;
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
      body: content,
      credentials: "include"
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
