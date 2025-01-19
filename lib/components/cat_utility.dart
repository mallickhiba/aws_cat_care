// Filename: cat_utility.dart
import 'dart:async';

import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatUtility {
  static Future<Map<String, String>> preloadCatNames(
      BuildContext context) async {
    final catBloc = context.read<GetCatBloc>();
    catBloc.add(GetCats());

    final catState =
        await catBloc.stream.firstWhere((state) => state is GetCatSuccess);
    if (catState is GetCatSuccess) {
      final catNames = {
        for (var cat in catState.cats) cat.catId: cat.catName,
      };
      return catNames;
    } else {
      throw Exception('Failed to load cat names');
    }
  }
}
