class CustomPageModel {
  String id;
  String slugName;
  String pageName;
  String content;

  CustomPageModel({this.id, this.slugName, this.pageName, this.content});

  CustomPageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slugName = json['slug_name'];
    pageName = json['page_name'];
    content = json['content'];
  }
}