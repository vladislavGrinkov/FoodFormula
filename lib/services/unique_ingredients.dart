List<dynamic> uniqueIngredients(List<dynamic> list) {
  List<dynamic> arr = [];
  list.forEach((item) {
    var i = arr.indexWhere(
      (val) => val["recipe"]['label'] == item["recipe"]['label'],
    );
    if (i <= -1) {
      arr.add(item);
    }
  });
  return arr;
}
