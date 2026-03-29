class FAQModel {
  String id;
  String question;
  String answer;
  String slugName;
  String sequence;
  String status;
  String dateCreated;
  String lastUpdated;

  FAQModel(
      {this.id,
        this.question,
        this.answer,
        this.slugName,
        this.sequence,
        this.status,
        this.dateCreated,
        this.lastUpdated});

  FAQModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    slugName = json['slug_name'];
    sequence = json['sequence'];
    status = json['status'];
    dateCreated = json['date_created'];
    lastUpdated = json['last_updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['slug_name'] = this.slugName;
    data['sequence'] = this.sequence;
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    data['last_updated'] = this.lastUpdated;
    return data;
  }
}