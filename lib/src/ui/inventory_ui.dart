import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/adventure_jumper_game.dart';
import '../player/player_inventory.dart';
import 'text_paint_extensions.dart';

/// Item management interface
/// Displays and manages the player's collected items and equipment
class InventoryUI extends PositionComponent with TapCallbacks {
  InventoryUI({
    required this.game,
    required this.screenSize,
    required this.inventory,
    this.onClose,
  }) : super(position: Vector2.zero(), size: screenSize);

  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  final PlayerInventory inventory;
  // Callbacks
  final void Function()? onClose;

  // UI components
  late final PositionComponent _background;
  late final TextComponent _titleText;
  late final PositionComponent _itemsPanel;
  late final PositionComponent _detailsPanel;
  late final PositionComponent _equipmentPanel;
  late final CloseButton _closeButton;
  // Item grid settings
  final int _gridColumns = 5;
  final double _slotSize = 50;
  final double _slotPadding = 5;

  // State - will be used in Sprint 3 for item selection
  // ignore: unused_field
  InventoryItem? _selectedItem;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create background overlay
    _createBackground();

    // Create title
    _createTitle();

    // Create panels
    _createItemsPanel();
    _createDetailsPanel();
    _createEquipmentPanel();

    // Create close button
    _createCloseButton();

    // Add entrance animations
    _addEntranceAnimations();
  }

  /// Create semi-transparent background
  void _createBackground() {
    _background = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = const Color(0xCC000000), // Semi-transparent black
    );

    add(_background);
  }

  /// Create inventory title
  void _createTitle() {
    _titleText = TextComponent(
      text: 'INVENTORY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(screenSize.x / 2, 40),
      anchor: Anchor.center,
    );

    add(_titleText);
  }

  /// Create panel for displaying items grid
  void _createItemsPanel() {
    // Panel container
    final double panelWidth =
        (_slotSize + _slotPadding * 2) * _gridColumns + 20;
    final double panelHeight = screenSize.y * 0.6;

    _itemsPanel = RectangleComponent(
      position: Vector2(screenSize.x * 0.25 - panelWidth / 2, 80),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = const Color(0x88333333), // Dark semi-transparent gray
    );
    add(_itemsPanel); // Panel title
    final TextComponent panelTitle = TextComponent(
      text: 'Items',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(panelWidth / 2, 20),
      anchor: Anchor.center,
    );

    _itemsPanel.add(panelTitle);

    // Create item slots
    _createItemSlots();
  }

  /// Create item slots in grid format
  void _createItemSlots() {
    // Will be expanded in future sprints with real inventory data
    // For now, create a grid of empty slots with a few example items

    const double startX = 10;
    const double startY = 50;

    // Create grid of slots
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < _gridColumns; col++) {
        final double slotX = startX + col * (_slotSize + _slotPadding * 2);
        final double slotY = startY + row * (_slotSize + _slotPadding * 2);

        final InventorySlot slot = InventorySlot(
          position: Vector2(slotX, slotY),
          size: Vector2(_slotSize, _slotSize),
          onPressed: () {
            // Item selection logic will be implemented in future sprints
          },
        );

        _itemsPanel.add(slot);

        // Add example items to a few slots
        if ((row == 0 && col == 0) ||
            (row == 1 && col == 2) ||
            (row == 3 && col == 4)) {
          final InventoryItemUI item = InventoryItemUI(
            position: Vector2(_slotSize / 2, _slotSize / 2),
            size: Vector2(_slotSize * 0.8, _slotSize * 0.8),
            itemName: 'Example Item',
            itemType: 'Consumable',
          );

          slot.add(item);
        }
      }
    }
  }

  /// Create panel for displaying selected item details
  void _createDetailsPanel() {
    final double panelWidth = screenSize.x * 0.4;
    final double panelHeight = screenSize.y * 0.25;

    _detailsPanel = RectangleComponent(
      position: Vector2(screenSize.x * 0.7 - panelWidth / 2, 80),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = const Color(0x88333333), // Dark semi-transparent gray
    );

    add(_detailsPanel);

    // Panel title
    final TextComponent<TextPaint> panelTitle = TextComponent(
      text: 'Item Details',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(panelWidth / 2, 20),
      anchor: Anchor.center,
    );

    _detailsPanel.add(panelTitle);

    // Item details - placeholder text
    final TextComponent<TextPaint> detailsText = TextComponent(
      text: 'Select an item to view its details',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      position: Vector2(panelWidth / 2, panelHeight / 2),
      anchor: Anchor.center,
    );

    _detailsPanel.add(detailsText);
  }

  /// Create panel for equipment slots
  void _createEquipmentPanel() {
    final double panelWidth = screenSize.x * 0.4;
    final double panelHeight = screenSize.y * 0.3;

    _equipmentPanel = RectangleComponent(
      position: Vector2(
        screenSize.x * 0.7 - panelWidth / 2,
        80 + screenSize.y * 0.27,
      ),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = const Color(0x88333333), // Dark semi-transparent gray
    );

    add(_equipmentPanel);

    // Panel title
    final TextComponent<TextPaint> panelTitle = TextComponent(
      text: 'Equipment',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(panelWidth / 2, 20),
      anchor: Anchor.center,
    );

    _equipmentPanel.add(panelTitle);

    // Equipment slots
    _createEquipmentSlots();
  }

  /// Create equipment slots with labels
  void _createEquipmentSlots() {
    final double slotSize = _slotSize * 1.2;
    final List<String> slotNames = <String>[
      'Weapon',
      'Armor',
      'Accessory 1',
      'Accessory 2',
    ];
    const double startY = 60;
    final double spacing = slotSize + 20;

    for (int i = 0; i < slotNames.length; i++) {
      // Slot label
      final TextComponent<TextPaint> label = TextComponent(
        text: slotNames[i],
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        position: Vector2(50, startY + i * spacing),
        anchor: Anchor.centerLeft,
      );

      _equipmentPanel.add(label);

      // Equipment slot
      final EquipmentSlot slot = EquipmentSlot(
        position: Vector2(
          _equipmentPanel.size.x - 80,
          startY + i * spacing - slotSize / 2,
        ),
        size: Vector2(slotSize, slotSize),
        slotType: slotNames[i],
        onPressed: () {
          // Equipment selection logic will be implemented in future sprints
        },
      );

      _equipmentPanel.add(slot);
    }
  }

  /// Create close button
  void _createCloseButton() {
    _closeButton = CloseButton(
      position: Vector2(screenSize.x - 40, 40),
      size: Vector2(30, 30),
      onPressed: () {
        if (onClose != null) onClose!();
      },
    );

    add(_closeButton);
  }

  /// Add entrance animations
  void _addEntranceAnimations() {
    // Background fades in
    _background.add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.01),
      ),
    );
    _background.add(
      OpacityEffect.fadeIn(
        EffectController(duration: 0.3),
      ),
    ); // Title slides in
    _titleText.position = Vector2(_titleText.position.x, -20);
    _titleText.add(
      MoveToEffect(
        Vector2(_titleText.position.x, 40),
        EffectController(
          duration: 0.4,
          curve: Curves.easeOutCubic,
        ),
      ),
    ); // Panels slide in
    _itemsPanel.position =
        Vector2(_itemsPanel.position.x - 100, _itemsPanel.position.y);
    _itemsPanel.add(
      MoveToEffect(
        Vector2(_itemsPanel.position.x + 100, _itemsPanel.position.y),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _detailsPanel.position =
        Vector2(_detailsPanel.position.x + 100, _detailsPanel.position.y);
    _detailsPanel.add(
      MoveToEffect(
        Vector2(_detailsPanel.position.x - 100, _detailsPanel.position.y),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _equipmentPanel.position =
        Vector2(_equipmentPanel.position.x + 100, _equipmentPanel.position.y);
    _equipmentPanel.add(
      MoveToEffect(
        Vector2(_equipmentPanel.position.x - 100, _equipmentPanel.position.y),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
          startDelay: 0.1,
        ),
      ),
    );
  }
}

/// Inventory slot component
class InventorySlot extends PositionComponent with TapCallbacks {
  InventorySlot({
    required Vector2 position,
    required Vector2 size,
    this.onPressed,
  }) : super(position: position, size: size);

  final void Function()? onPressed;

  // Visual state
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Determine slot color based on state
    Color slotColor = const Color(0xFF444444);
    Color borderColor = const Color(0xFF666666);

    if (_isHovered) {
      borderColor = const Color(0xFFAAAAAA);
    }

    if (_isPressed) {
      slotColor = const Color(0xFF555555);
    }

    // Draw slot background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final Paint slotPaint = Paint()..color = slotColor;
    canvas.drawRRect(rrect, slotPaint);

    // Draw slot border
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  void onHoverEnter() {
    _isHovered = true;
  }

  void onHoverExit() {
    _isHovered = false;
  }
}

/// Equipment slot component
class EquipmentSlot extends PositionComponent with TapCallbacks {
  EquipmentSlot({
    required Vector2 position,
    required Vector2 size,
    required this.slotType,
    this.onPressed,
  }) : super(position: position, size: size);
  final String slotType;
  final void Function()? onPressed;
  // Visual state
  bool _isHovered = false;
  bool _isPressed = false;

  // Equipment data - will be used in Sprint 3 for equipment system
  // ignore: unused_field
  final bool _isEquipped = false;
  // ignore: unused_field
  InventoryItem? _equippedItem;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Determine slot color based on state and type
    Color slotColor = const Color(0xFF444444);
    Color borderColor = const Color(0xFF666666);

    // Different border color based on equipment type
    switch (slotType) {
      case 'Weapon':
        borderColor = const Color(0xFFAA4444);
        break;
      case 'Armor':
        borderColor = const Color(0xFF4444AA);
        break;
      case 'Accessory 1':
      case 'Accessory 2':
        borderColor = const Color(0xFF44AA44);
        break;
    }

    if (_isHovered) {
      borderColor = borderColor.withAlpha(220);
    }

    if (_isPressed) {
      slotColor = const Color(0xFF555555);
    }

    // Draw slot background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final Paint slotPaint = Paint()..color = slotColor;
    canvas.drawRRect(rrect, slotPaint);

    // Draw slot border
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint); // Draw icon for slot type
    final String iconText = _getSlotIcon();
    const TextStyle textStyle = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.5),
      fontSize: 16,
    );

    final TextPaint textPaint = TextPaint(style: textStyle);
    // Calculate the text size using the textRenderer
    final Vector2 textSize = Vector2(
      textPaint.measureTextWidth(iconText),
      textStyle.fontSize! * 1.2,
    );
    final Vector2 textPosition = Vector2(
      size.x / 2 - textSize.x / 2,
      size.y / 2 - textSize.y / 2,
    );

    textPaint.render(canvas, iconText, textPosition);
  }

  /// Get icon text for the slot type
  String _getSlotIcon() {
    switch (slotType) {
      case 'Weapon':
        return '⚔';
      case 'Armor':
        return '🛡';
      case 'Accessory 1':
      case 'Accessory 2':
        return '💍';
      default:
        return '?';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  void onHoverEnter() {
    _isHovered = true;
  }

  void onHoverExit() {
    _isHovered = false;
  }
}

/// Visual representation of an inventory item
class InventoryItemUI extends PositionComponent {
  InventoryItemUI({
    required Vector2 position,
    required Vector2 size,
    required this.itemName,
    required this.itemType,
    this.rarity = ItemRarity.common,
  }) : super(position: position, size: size, anchor: Anchor.center);

  final String itemName;
  final String itemType;
  final ItemRarity rarity;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Get color based on rarity
    final Color itemColor = _getRarityColor();

    // Draw item background
    final Rect rect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.x,
      height: size.y,
    );
    final Paint itemPaint = Paint()
      ..color = Color.fromRGBO(
        (itemColor.r * 255.0).round() & 0xff,
        (itemColor.g * 255.0).round() & 0xff,
        (itemColor.b * 255.0).round() & 0xff,
        0.7,
      );
    canvas.drawRect(rect, itemPaint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = itemColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, borderPaint);

    // For actual game implementation, would render item sprite here
    // For now, just use placeholder text
    final TextPaint textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );

    textPaint.render(canvas, 'Item', Vector2(-8, -5));
  }

  /// Get color based on item rarity
  Color _getRarityColor() {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFFAAAAAA); // Gray
      case ItemRarity.uncommon:
        return const Color(0xFF55AA55); // Green
      case ItemRarity.rare:
        return const Color(0xFF5555AA); // Blue
      case ItemRarity.epic:
        return const Color(0xFF8855AA); // Purple
      case ItemRarity.legendary:
        return const Color(0xFFAA5522); // Orange
    }
  }
}

/// Close button component
class CloseButton extends PositionComponent with TapCallbacks {
  CloseButton({
    required Vector2 position,
    required Vector2 size,
    this.onPressed,
  }) : super(position: position, size: size, anchor: Anchor.center);

  final void Function()? onPressed;

  // Visual state
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Determine button color based on state
    Color buttonColor = const Color(0xAAFF3333);

    if (_isHovered) {
      buttonColor = const Color(0xFFFF5555);
    }

    if (_isPressed) {
      buttonColor = const Color(0xFFAA2222);
    }

    // Draw button background
    final Rect circleRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final Paint circlePaint = Paint()..color = buttonColor;
    canvas.drawOval(circleRect, circlePaint);

    // Draw X
    final Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double padding = 7;

    canvas.drawLine(
      const Offset(padding, padding),
      Offset(size.x - padding, size.y - padding),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.x - padding, padding),
      Offset(padding, size.y - padding),
      linePaint,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  void onHoverEnter() {
    _isHovered = true;
    add(
      ScaleEffect.to(
        Vector2(1.1, 1.1),
        EffectController(duration: 0.1),
      ),
    );
  }

  void onHoverExit() {
    _isHovered = false;
    add(
      ScaleEffect.to(
        Vector2(1, 1),
        EffectController(duration: 0.1),
      ),
    );
  }
}

/// Placeholder inventory item structure
/// Will be replaced with actual item class from PlayerInventory in future sprints
class InventoryItem {
  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    this.stackable = false,
    this.maxStack = 1,
    this.quantity = 1,
    this.stats = const <String, int>{},
  });

  final String id;
  final String name;
  final String description;
  final String type;
  final ItemRarity rarity;
  final bool stackable;
  final int maxStack;
  int quantity;
  final Map<String, int> stats;
}

/// Item rarity enum
enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}
