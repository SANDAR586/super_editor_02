import 'package:example/demos/features/feature_demo_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class HashTagsFeatureDemo extends StatefulWidget {
  const HashTagsFeatureDemo({super.key});

  @override
  State<HashTagsFeatureDemo> createState() => _HashTagsFeatureDemoState();
}

class _HashTagsFeatureDemoState extends State<HashTagsFeatureDemo> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;

  late final PatternTagPlugin _hashTagPlugin;

  final _tags = <IndexedTag>[];

  @override
  void initState() {
    super.initState();

    _document = MutableDocument(nodes: [
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(""),
      ),
    ]);
    _composer = MutableDocumentComposer();
    _editor = Editor(
      editables: {
        Editor.documentKey: _document,
        Editor.composerKey: _composer,
      },
      requestHandlers: [
        ...defaultRequestHandlers,
      ],
    );

    _hashTagPlugin = PatternTagPlugin() //
      ..tagIndex.addListener(_updateHashTagList);
  }

  @override
  void dispose() {
    _hashTagPlugin.tagIndex.removeListener(_updateHashTagList);
    super.dispose();
  }

  void _updateHashTagList() {
    setState(() {
      _tags
        ..clear()
        ..addAll(_hashTagPlugin.tagIndex.getAllTags());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDemoScaffold(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildEditor(),
          ),
          _buildTagList(),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return SuperEditor(
      editor: _editor,
      document: _document,
      composer: _composer,
      stylesheet: defaultStylesheet.copyWith(
        inlineTextStyler: (attributions, existingStyle) {
          TextStyle style = defaultInlineTextStyler(attributions, existingStyle);

          if (attributions.whereType<PatternTagAttribution>().isNotEmpty) {
            style = style.copyWith(
              color: Colors.orange,
            );
          }

          return style;
        },
        addRulesAfter: [
          ...darkModeStyles,
        ],
      ),
      documentOverlayBuilders: [
        DefaultCaretOverlayBuilder(
          caretStyle: CaretStyle().copyWith(color: Colors.redAccent),
        ),
      ],
      plugins: {
        _hashTagPlugin,
      },
    );
  }

  Widget _buildTagList() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1, color: Colors.white.withOpacity(0.1)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: _tags.isNotEmpty
            ? SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tag in _tags) //
                      Chip(label: Text(tag.tag.raw)),
                  ],
                ),
              )
            : Text(
                "NO TAGS",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.1),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
