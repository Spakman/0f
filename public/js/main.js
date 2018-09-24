window.onload = function() {
  document.execCommand("defaultParagraphSeparator", false, "p");
  document.execCommand("insertBrOnReturn", false, false);

  let article = new Article(
    document.getElementById("editableArticle"),
    document.body.parentElement,
    document.body
  );

  let editMenu = new EditMenu(
    document.getElementById("editMenu"),
    article,
    document.getElementById("hrefModal"),
    document.getElementById("private"),
    document.getElementById("move"),
    document.getElementById("delete"),
    document.getElementById("location"),
    document.getElementById("style"),
    document.getElementById("link"),
    document.getElementById("close")
  );

  let keyboard = new Keyboard(article, editMenu);
};
