bool compareTwoArr(receipt, basket) {
  var result = receipt
      .where((item) =>
          basket.where((elem) => elem == item).length > 0 ? true : false)
      .toList();

  if (result.length == 0) {
    return (false);
  }
  return (true);
}
