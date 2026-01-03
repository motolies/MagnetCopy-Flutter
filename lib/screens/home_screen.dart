import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/magnet_provider.dart';
import '../models/magnet_link.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  static const _urlHandlerChannel = MethodChannel('magnet_copy/url_handler');

  bool _isAlwaysOnTop = false;
  bool _isMagnetRegistered = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMagnetRegistration();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkMagnetRegistration() async {
    try {
      final isRegistered = await _urlHandlerChannel.invokeMethod<bool>('isDefaultHandler');
      setState(() {
        _isMagnetRegistered = isRegistered ?? false;
      });
    } catch (e) {
      debugPrint('Failed to check magnet registration: $e');
    }
  }

  Future<void> _toggleMagnetRegistration() async {
    try {
      await _urlHandlerChannel.invokeMethod('registerAsDefaultHandler');
      await _checkMagnetRegistration();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Magnet 핸들러로 등록되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to register magnet handler: $e');
    }
  }

  Future<void> _toggleAlwaysOnTop() async {
    _isAlwaysOnTop = !_isAlwaysOnTop;
    await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
    setState(() {});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(child: _buildLinkList(context)),
          _buildStatusBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<MagnetProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: provider.hasNewLink
          ? Colors.red.shade100
          : Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: provider.isEmpty
                ? null
                : () {
                    provider.clearAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('목록이 초기화되었습니다'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('초기화'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: provider.isEmpty
                ? null
                : () async {
                    await provider.copyAllToClipboard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${provider.count}개 링크가 복사되었습니다'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.copy_all, size: 18),
            label: const Text('전체 복사'),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _isMagnetRegistered,
                onChanged: (_) => _toggleMagnetRegistration(),
              ),
              const Text('Magnet 등록'),
              const SizedBox(width: 16),
              Checkbox(
                value: _isAlwaysOnTop,
                onChanged: (_) => _toggleAlwaysOnTop(),
              ),
              const Text('항상 위'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkList(BuildContext context) {
    final provider = context.watch<MagnetProvider>();

    if (provider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '수집된 Magnet 링크가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '브라우저에서 Magnet 링크를 클릭하면\n이곳에 표시됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.hasNewLink) {
        _scrollToBottom();
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.links.length,
      itemBuilder: (context, index) {
        final link = provider.links[index];
        return _buildLinkTile(context, link, index + 1);
      },
    );
  }

  Widget _buildLinkTile(BuildContext context, MagnetLink link, int number) {
    final provider = context.read<MagnetProvider>();

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        link.displayName,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        link.uri,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: '복사',
            onPressed: () async {
              await provider.copyLinkToClipboard(link);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('링크가 복사되었습니다'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: '삭제',
            onPressed: () => provider.removeLink(link),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final provider = context.watch<MagnetProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '총 ${provider.count}개 링크',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
