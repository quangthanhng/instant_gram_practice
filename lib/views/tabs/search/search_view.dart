import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/views/components/search_grid_view.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/extensions/dismiss_keyboard.dart';

class SearchView extends HookConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final searchTerm = useState('');

    useEffect(() {
      controller.addListener(() {
        searchTerm.value = controller.text;
      });
      return () {};
    }, [controller]);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: Strings.enterYourSearchTermHere,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 22,
                  ),
                  suffixIcon: searchTerm.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                            dissMissKeyboard();
                          },
                          icon: Icon(
                            Icons.cancel_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),
        ),
        SearchGridView(searchTerm: searchTerm.value),
      ],
    );
  }
}
