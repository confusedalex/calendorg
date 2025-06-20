import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

Widget eventListPage() => Center(
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: BlocBuilder<OrgFilesBloc, OrgFilesState>(
            // builder: (context, state) => Text(state.toMarkup()),
            builder: (context, state) => SingleChildScrollView(
              child: Column(
                  children: state.documentsMap.values
                      .map(
                        (e) => PrettyDiffText(
                            oldText: "bla", newText: e.toMarkup()),
                      )
                      .toList()),
            ),
          )),
    );
