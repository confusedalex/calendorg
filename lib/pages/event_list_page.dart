import 'package:calendorg/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

Widget eventListPage(String firstRead) => Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: BlocBuilder<OrgDocumentCubit, OrgDocument>(
          // builder: (context, state) => Text(state.toMarkup()),
          builder: (context, state) =>
              PrettyDiffText(oldText: firstRead, newText: state.toMarkup()),
        ),
      ),
    );
