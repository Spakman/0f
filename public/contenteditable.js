window.onload = function() {
  document.execCommand("defaultParagraphSeparator", false, "p");
  document.execCommand("insertBrOnReturn", false, false);

  let article = new Article(document.getElementById("editableArticle"), document.body);
  let createLink = new CreateLink(document.getElementById("createLinkForm"), document.getElementById("createLinkHref"), document.getElementById("createLinkButton"), article);
  let locationChanger = new LocationChanger(document.getElementById("locationForm"), document.getElementById("locationHref"), document.getElementById("locationButton"), article);
  new EditMenu(
    document.getElementById("editMenu"),
    document.getElementById("hideMenu"),
    document.getElementById("createLink"),
    document.getElementById("location"),
    document.getElementById("textStyle"),
    article,
    createLink,
    locationChanger
  );
};


class EditMenu {
  constructor(element, closeMenuElement, linkMenuElement, locationMenuElement, textStyleElement, article, createLink, locationChanger) {
    this.element = element;
    this.closeMenuElement = closeMenuElement;
    this.linkMenuElement = linkMenuElement;
    this.locationMenuElement = locationMenuElement;
    this.textStyleElement = textStyleElement;
    this.article = article;
    this.hide();
    this.listenToArticleEditingState();
    this.setupCloseMenuElement();
    this.setupTextStyleMenu();
    this.createLink = createLink;
    this.locationChanger = locationChanger;
    this.setupLinkMenuElement();
    this.setupLocationMenuElement();
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

    this.article.element.addEventListener("input", this.setMenuState.bind(this));
    this.article.element.addEventListener("click", this.setMenuState.bind(this));
  }

  elementUnderCursor() {
    let selection = window.getSelection();
    if (selection.rangeCount) {
      let selectionRange = selection.getRangeAt(0);
      let element = this.getContainer(selectionRange.endContainer);
      if(element) {
        return element.nodeName;
      }
      else {
        return "";
      }
    }
  }

  getContainer(node) {
    while (node) {
      if (node.nodeType == 1 && /^(P|H2|UL)$/i.test(node.nodeName)) {
        return node;
      }
      node = node.parentNode;
    }
  }

  setMenuState() {
    this.textStyleElement.value = this.elementUnderCursor();
  }

  setupTextStyleMenu() {
    this.textStyleElement.addEventListener("change", function(ev) {
      let currentElement = this.elementUnderCursor();
      let selectedStyle = this.textStyleElement.value;

      if(selectedStyle == "UL" && currentElement != "UL") {
        document.execCommand('insertUnorderedList', false);
      }
      else if (selectedStyle != "UL" && currentElement == "UL") {
        document.execCommand('insertUnorderedList', false);
        document.execCommand("formatBlock", false, selectedStyle);
      }

      else {
        document.execCommand("formatBlock", false, selectedStyle);
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

  setupLocationMenuElement() {
    this.locationMenuElement.addEventListener("click", function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      this.locationChanger.toggle();
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
    if(savedSel) {
      for(var i = 0, len = savedSel.length; i < len; ++i) {
        sel.addRange(savedSel[i]);
      }
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


class LocationChanger {
  constructor(formElement, hrefElement, buttonElement, article) {
    this.formElement = formElement;
    this.hrefElement = hrefElement;
    this.buttonElement = buttonElement;
    this.article = article;
    this.onlyAllowButtonPressWhenHrefIsNotEmpty();
    this.setupGoButton();
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

  toggle() {
    if(this.formElement.classList.contains("hidden")) {
      this.display();
    }
    else {
      this.hide();
    }
  }

  display() {
    this.formElement.classList.remove("hidden");
    this.hrefElement.focus();
  }

  hide() {
    this.formElement.classList.add("hidden");
    this.hrefElement.value = "";
    this.article.focus();
  }

  setupGoButton() {
    this.buttonElement.addEventListener("click", function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      window.location.href = this.hrefElement.value;
    }.bind(this));
  }
}


class Article {
  constructor(element, body) {
    this.element = element;
    this.pageSaver = new PageSaver();
    this.ensureLinksAreClickable();
    this.makeElementEditable();
    this.body = body;
  }

  ensureLinksAreClickable() {
    Array.from(this.element.getElementsByTagName("a")).forEach(function(a) {
      a.removeEventListener("click", this.stopPropagation);
      a.addEventListener("click", this.stopPropagation);
    }.bind(this));
  }

  makeElementEditable() {
    this.element.addEventListener("click", function(ev) {
      this.element.contentEditable = true;
      this.focus();
    }.bind(this));

    this.element.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        this.stopEditing();
      }
    }.bind(this));

    this.element.addEventListener("input", this.save.bind(this));
  }

  focus() {
    this.element.focus();
    this.body.classList.add("editing");
  }

  save() {
    this.pageSaver.save(this.element.innerHTML);
  }

  stopEditing() {
    this.element.contentEditable = false;
    this.body.classList.remove("editing");
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
