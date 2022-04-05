List<dynamic> uniqueList(list) {
  var resArr = [];
  list.forEach((item) {
    var i = resArr.indexWhere((val) => val["_name"] == item["_name"]);
    if (i <= -1) {
      resArr.add({"_name": item["_name"]});
    }
  });
  return resArr.toList();
}
