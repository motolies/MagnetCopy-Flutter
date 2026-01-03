import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/magnet_link.dart';

enum AddLinkResult { added, duplicate, invalid }

class MagnetProvider extends ChangeNotifier {
  final Set<String> _uris = {};
  final List<MagnetLink> _links = [];
  bool _hasNewLink = false;

  List<MagnetLink> get links => List.unmodifiable(_links);
  int get count => _links.length;
  bool get isEmpty => _links.isEmpty;
  bool get hasNewLink => _hasNewLink;

  AddLinkResult addLink(String uri) {
    if (!uri.startsWith('magnet:')) return AddLinkResult.invalid;

    if (_uris.contains(uri)) {
      return AddLinkResult.duplicate;
    }

    _uris.add(uri);
    _links.add(MagnetLink(uri: uri));
    _hasNewLink = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _hasNewLink = false;
      notifyListeners();
    });

    return AddLinkResult.added;
  }

  void removeLink(MagnetLink link) {
    _uris.remove(link.uri);
    _links.remove(link);
    notifyListeners();
  }

  void clearAll() {
    _uris.clear();
    _links.clear();
    notifyListeners();
  }

  Future<void> copyAllToClipboard() async {
    if (_links.isEmpty) return;

    final text = _links.map((link) => link.uri).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> copyLinkToClipboard(MagnetLink link) async {
    await Clipboard.setData(ClipboardData(text: link.uri));
  }
}
