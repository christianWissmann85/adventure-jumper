import '../ui/dialogue_ui.dart';

/// Sample conversations for testing the DialogueUI system
/// This file contains example dialogue data for various NPCs including Mira
class SampleConversations {
  /// Simple linear conversation sequence
  static List<DialogueEntry> getMiraIntroductionSequence() {
    return [
      DialogueEntry(
        speakerName: 'Mira',
        text: 'Ah, a new face in the Archive. Welcome, young seeker.',
        dialogueId: 'mira_intro_1',
        nextDialogueId: 'mira_intro_2',
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
      DialogueEntry(
        speakerName: 'Mira',
        text:
            'I am Mira, Keeper of these ancient texts. The knowledge contained here spans millennia.',
        dialogueId: 'mira_intro_2',
        nextDialogueId: 'mira_intro_3',
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
      DialogueEntry(
        speakerName: 'Mira',
        text:
            'Tell me, what brings you to the Archive? Are you here to learn, or perhaps you seek something specific?',
        dialogueId: 'mira_intro_3',
        choices: [
          'I want to learn about the Keepers',
          'I\'m looking for adventure',
          'Just exploring',
        ],
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
    ];
  }

  /// Conversation tree using DialogueNode system
  static Map<String, DialogueNode> getMiraConversationTree() {
    return {
      'start': DialogueNode(
        id: 'start',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'Greetings, traveler. I sense great potential in you.',
          dialogueId: 'mira_tree_start',
          choices: ['Who are you?', 'What is this place?', 'I must go'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Who are you?': 'about_mira',
          'What is this place?': 'about_archive',
          'I must go': 'farewell',
        },
      ),
      'about_mira': DialogueNode(
        id: 'about_mira',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I am Mira, scholar and guardian of the Keeper\'s Archive. I have spent decades studying the ancient arts of dimensional travel.',
          dialogueId: 'mira_about_self',
          choices: [
            'Tell me about the Keepers',
            'What do you study here?',
            'That sounds fascinating',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Tell me about the Keepers': 'about_keepers',
          'What do you study here?': 'about_studies',
          'That sounds fascinating': 'mira_pleased',
        },
      ),
      'about_archive': DialogueNode(
        id: 'about_archive',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'This is the Keeper\'s Archive, a repository of knowledge gathered from across the dimensional planes. Every tome here contains secrets of the universe.',
          dialogueId: 'mira_about_archive',
          choices: [
            'How do I access this knowledge?',
            'Who are the Keepers?',
            'Amazing...',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'How do I access this knowledge?': 'accessing_knowledge',
          'Who are the Keepers?': 'about_keepers',
          'Amazing...': 'mira_pleased',
        },
      ),
      'about_keepers': DialogueNode(
        id: 'about_keepers',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Keepers are an ancient order dedicated to preserving knowledge and maintaining balance between dimensions. We are the guardians of reality itself.',
          dialogueId: 'mira_about_keepers',
          choices: [
            'How do I become a Keeper?',
            'That\'s a big responsibility',
            'Tell me more about dimensions',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'How do I become a Keeper?': 'becoming_keeper',
          'That\'s a big responsibility': 'keeper_responsibility',
          'Tell me more about dimensions': 'about_dimensions',
        },
      ),
      'about_studies': DialogueNode(
        id: 'about_studies',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I research dimensional rifts, the paths between worlds. My current project involves understanding how the recent Fracture has affected travel between realms.',
          dialogueId: 'mira_about_studies',
          choices: [
            'What is the Fracture?',
            'Can you teach me?',
            'Sounds dangerous',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'What is the Fracture?': 'about_fracture',
          'Can you teach me?': 'teaching_offer',
          'Sounds dangerous': 'danger_acknowledgment',
        },
      ),
      'mira_pleased': DialogueNode(
        id: 'mira_pleased',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I can see you have an inquisitive mind. That is good - curiosity is the first step toward wisdom.',
          dialogueId: 'mira_pleased',
          choices: [
            'I\'d like to learn more',
            'Do you have any advice?',
            'Thank you',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'I\'d like to learn more': 'learning_more',
          'Do you have any advice?': 'mira_advice',
          'Thank you': 'polite_farewell',
        },
      ),
      'teaching_offer': DialogueNode(
        id: 'teaching_offer',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Perhaps... You show promise, but first you must prove your dedication. Are you willing to undertake a task for me?',
          dialogueId: 'mira_teaching_offer',
          choices: ['Yes, I\'m ready', 'What kind of task?', 'Maybe later'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Yes, I\'m ready': 'quest_accept',
          'What kind of task?': 'quest_details',
          'Maybe later': 'quest_declined',
        },
      ),
      'quest_accept': DialogueNode(
        id: 'quest_accept',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Excellent! There are several ancient texts scattered throughout Luminara. Gather them for me, and I will begin your training.',
          dialogueId: 'mira_quest_accept',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        nextNodeId: 'quest_given',
      ),
      'quest_given': DialogueNode(
        id: 'quest_given',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The texts glow with a faint blue light - you\'ll know them when you see them. Return to me when you have found at least three.',
          dialogueId: 'mira_quest_given',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
      ),
      'farewell': DialogueNode(
        id: 'farewell',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Very well. Should you ever wish to learn the secrets of the Archive, you know where to find me.',
          dialogueId: 'mira_farewell',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
      ),
      'polite_farewell': DialogueNode(
        id: 'polite_farewell',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'May the Archive\'s wisdom guide your path, young seeker. Return anytime you wish to expand your knowledge.',
          dialogueId: 'mira_polite_farewell',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
      ),
    };
  }

  /// Enhanced conversation tree with conditions and state management
  static Map<String, DialogueNode> getEnhancedMiraConversationTree() {
    return {
      'start': DialogueNode(
        id: 'start',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'Greetings, traveler. I sense great potential in you.',
          dialogueId: 'mira_enhanced_start',
          choices: ['Who are you?', 'What is this place?', 'I must go'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'met_mira': true,
            'conversation_count': {'operation': 'add', 'value': 1},
          },
          onShowCallbacks: ['debug_print:Started conversation with Mira'],
        ),
        choiceNodeIds: {
          'Who are you?': 'about_mira',
          'What is this place?': 'about_archive',
          'I must go': 'farewell',
        },
      ),
      'about_mira_first_time': DialogueNode(
        id: 'about_mira_first_time',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I am Mira, scholar and guardian of the Keeper\'s Archive. Welcome to my domain.',
          dialogueId: 'mira_about_self_first',
          choices: ['Tell me about the Keepers', 'What do you study here?'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {'learned_mira_identity': true},
        ),
        conditions: {
          'node_visited': 'about_mira',
          'counter_greater_than': {'counter': 'mira_about_visits', 'value': 0},
        },
        choiceNodeIds: {
          'Tell me about the Keepers': 'about_keepers',
          'What do you study here?': 'about_studies',
        },
        maxVisits: 1,
      ),
      'about_mira_returning': DialogueNode(
        id: 'about_mira_returning',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'As I mentioned before, I am the guardian of this Archive. Is there something specific you wish to know?',
          dialogueId: 'mira_about_self_returning',
          choices: [
            'Tell me about the Keepers',
            'What do you study here?',
            'Nothing else',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'flag_equals': {'flag': 'learned_mira_identity', 'value': true},
        },
        choiceNodeIds: {
          'Tell me about the Keepers': 'about_keepers',
          'What do you study here?': 'about_studies',
          'Nothing else': 'polite_farewell',
        },
      ),
      'quest_available': DialogueNode(
        id: 'quest_available',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Actually, I have a task that might interest someone of your... capabilities. Are you willing to help?',
          dialogueId: 'mira_quest_available',
          choices: [
            'What kind of task?',
            'I\'m ready to help',
            'Not right now',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'flag_equals': {'flag': 'learned_mira_identity', 'value': true},
          'flag_not_exists': 'quest_offered',
        },
        choiceNodeIds: {
          'What kind of task?': 'quest_details',
          'I\'m ready to help': 'quest_accept_immediate',
          'Not right now': 'quest_declined',
        },
      ),
      'quest_completed_response': DialogueNode(
        id: 'quest_completed_response',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Excellent work! You have proven yourself worthy. The knowledge of the Archive is now open to you.',
          dialogueId: 'mira_quest_completed',
          choices: ['Thank you', 'What can I learn now?'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'archive_access': true,
            'mira_approval': {'operation': 'add', 'value': 10},
          },
        ),
        conditions: {
          'flag_equals': {'flag': 'quest_completed', 'value': true},
        },
        choiceNodeIds: {
          'Thank you': 'polite_farewell',
          'What can I learn now?': 'teaching_available',
        },
        priority: 10, // High priority for quest completion
      ),
      'about_mira': DialogueNode(
        id: 'about_mira',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I am Mira, scholar and guardian of this Archive. It\'s a pleasure to meet someone interested in learning.',
          dialogueId: 'mira_about_basic',
          choices: ['Tell me more', 'What do you do here?', 'Interesting'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'mira_about_visits': {'operation': 'add', 'value': 1},
          },
        ),
        choiceNodeIds: {
          'Tell me more': 'about_mira_first_time',
          'What do you do here?': 'about_studies',
          'Interesting': 'polite_response',
        },
      ),
      'about_archive': DialogueNode(
        id: 'about_archive',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'This is the Keeper\'s Archive, a repository of knowledge from across dimensions.',
          dialogueId: 'mira_about_archive_enhanced',
          choices: ['Tell me more', 'How can I access this knowledge?'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Tell me more': 'about_keepers',
          'How can I access this knowledge?': 'accessing_knowledge',
        },
      ),
      'about_keepers': DialogueNode(
        id: 'about_keepers',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Keepers are an ancient order dedicated to preserving knowledge and maintaining balance.',
          dialogueId: 'mira_about_keepers_enhanced',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        nextNodeId: 'polite_farewell',
      ),
      'about_studies': DialogueNode(
        id: 'about_studies',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'I study dimensional rifts and the paths between worlds.',
          dialogueId: 'mira_about_studies_enhanced',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        nextNodeId: 'polite_farewell',
      ),
      'polite_response': DialogueNode(
        id: 'polite_response',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I\'m glad you find it interesting. Knowledge is a wonderful thing.',
          dialogueId: 'mira_polite_response',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        nextNodeId: 'polite_farewell',
      ),
      'accessing_knowledge': DialogueNode(
        id: 'accessing_knowledge',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'Knowledge must be earned through dedication and wisdom.',
          dialogueId: 'mira_accessing_knowledge',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        nextNodeId: 'polite_farewell',
      ),
      'polite_farewell': DialogueNode(
        id: 'polite_farewell',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'May wisdom guide your path, traveler.',
          dialogueId: 'mira_polite_farewell_enhanced',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
      ),
      'farewell': DialogueNode(
        id: 'farewell',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text: 'Safe travels. The Archive will be here when you return.',
          dialogueId: 'mira_farewell_enhanced',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
      ),
    };
  }

  /// T3.9.1: Mira's Enhanced Introduction Dialogue Content
  /// Comprehensive dialogue that introduces Luminara, player's situation, and world lore
  static List<DialogueEntry> getMiraIntroductionDialogue() {
    return [
      DialogueEntry(
        speakerName: 'Mira',
        text:
            'Hold, stranger. You carry the scent of distant realms... and something else. Something I have not sensed in centuries.',
        dialogueId: 'mira_introduction_1',
        useTypewriter: true,
        pauseAfterPunctuation: true,
        stateChanges: {
          'first_meeting_mira': true,
          'luminara_introduction_started': true,
        },
      ),
      DialogueEntry(
        speakerName: 'Mira',
        text:
            'Welcome to Luminara, the Crystal Spire. I am Mira, Keeper and Guardian of this Archive. The floating quill beside me is Quillheart, my research companion.',
        dialogueId: 'mira_introduction_2',
        useTypewriter: true,
        pauseAfterPunctuation: true,
        stateChanges: {
          'learned_mira_name': true,
          'learned_luminara_name': true,
        },
      ),
      DialogueEntry(
        speakerName: 'Mira',
        text:
            'You have arrived at a most peculiar time. The Aether currents have been... unstable. Tell me, do you remember how you came to be here?',
        dialogueId: 'mira_introduction_3',
        choices: [
          'I... I\'m not entirely sure',
          'I was pulled through some kind of portal',
          'Where exactly am I?',
        ],
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
    ];
  }

  /// T3.9.2: Comprehensive Mira Conversation Tree for First Meeting
  /// Includes introduction paths, Luminara exposition, and world lore
  static Map<String, DialogueNode> getMiraFirstMeetingTree() {
    return {
      'first_greeting': DialogueNode(
        id: 'first_greeting',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Peace, traveler. You have found sanctuary within the Keeper\'s Archive. The crystals sing of your arrival - they have been restless since you appeared.',
          dialogueId: 'mira_first_greeting',
          choices: [
            'Who are you?',
            'What is this place?',
            'Crystals... sing?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'met_mira': true,
            'archive_discovered': true,
          },
          onShowCallbacks: ['debug_print:Player meets Mira for first time'],
        ),
        choiceNodeIds: {
          'Who are you?': 'mira_introduction',
          'What is this place?': 'luminara_explanation',
          'Crystals... sing?': 'crystal_explanation',
        },
      ),
      'mira_introduction': DialogueNode(
        id: 'mira_introduction',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I am Mira of the Silver Quill, last of my Keeper lineage. I have tended this Archive for three decades, preserving the wisdom of ages past and... preparing for what is to come.',
          dialogueId: 'mira_self_introduction',
          choices: [
            'What are the Keepers?',
            'What do you mean, "preparing"?',
            'You seem young for three decades of work',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_mira_identity': true,
            'learned_keeper_concept': true,
          },
        ),
        choiceNodeIds: {
          'What are the Keepers?': 'keeper_explanation',
          'What do you mean, "preparing"?': 'prophecy_hint',
          'You seem young for three decades of work': 'mira_age_mystery',
        },
      ),
      'luminara_explanation': DialogueNode(
        id: 'luminara_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'This is Luminara, the Crystal Spire - crown jewel of the floating realm of Aetheris. You stand within the Keeper\'s Archive, built around the greatest Aether Well in all the known dimensions.',
          dialogueId: 'luminara_introduction',
          choices: [
            'Floating realm?',
            'What\'s an Aether Well?',
            'How did I get here?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_aetheris': true,
            'learned_aether_well': true,
          },
        ),
        choiceNodeIds: {
          'Floating realm?': 'aetheris_explanation',
          'What\'s an Aether Well?': 'aether_well_explanation',
          'How did I get here?': 'arrival_mystery',
        },
      ),
      'crystal_explanation': DialogueNode(
        id: 'crystal_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Ah, you hear them too? Few possess such sensitivity to the Aether resonance. The crystals throughout Luminara are living conduits of dimensional energy. They react to... significant events.',
          dialogueId: 'crystal_resonance_explanation',
          choices: [
            'Am I a significant event?',
            'What do they sound like to you?',
            'Is this normal?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'crystal_sensitivity_discovered': true,
            'aether_sensitivity_hint': true,
          },
        ),
        choiceNodeIds: {
          'Am I a significant event?': 'player_significance',
          'What do they sound like to you?': 'crystal_song_description',
          'Is this normal?': 'crystal_abnormality',
        },
      ),
      'keeper_explanation': DialogueNode(
        id: 'keeper_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Keepers are... were... an ancient order dedicated to maintaining the balance between dimensions. We guard knowledge, protect the Aether Wells, and watch for signs of the Fracture\'s return.',
          dialogueId: 'keeper_order_explanation',
          choices: [
            'Were? What happened to them?',
            'What is the Fracture?',
            'How do you protect Aether Wells?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_keeper_purpose': true,
            'fracture_mentioned': true,
          },
        ),
        choiceNodeIds: {
          'Were? What happened to them?': 'keeper_tragedy',
          'What is the Fracture?': 'fracture_explanation',
          'How do you protect Aether Wells?': 'well_protection',
        },
      ),
      'aetheris_explanation': DialogueNode(
        id: 'aetheris_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Aetheris is a realm of floating islands suspended in an endless sky, held aloft by the power of Aether Wells. Each island is a world unto itself, connected by streams of pure dimensional energy.',
          dialogueId: 'aetheris_world_explanation',
          choices: [
            'How many islands are there?',
            'What happens if you fall?',
            'Can you travel between them?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_world_structure': true,
            'dimensional_travel_concept': true,
          },
        ),
        choiceNodeIds: {
          'How many islands are there?': 'island_count',
          'What happens if you fall?': 'void_explanation',
          'Can you travel between them?': 'travel_methods',
        },
      ),
      'aether_well_explanation': DialogueNode(
        id: 'aether_well_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Aether Wells are focal points of dimensional energy - the lifeblood of our realm. They maintain the floating islands, power our magic, and serve as gateways between worlds. The Well beneath us is... special.',
          dialogueId: 'aether_well_details',
          choices: [
            'Special how?',
            'Can I see this Well?',
            'Are they dangerous?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Special how?': 'luminara_well_significance',
          'Can I see this Well?': 'well_tour_offer',
          'Are they dangerous?': 'well_dangers',
        },
      ),
      'player_significance': DialogueNode(
        id: 'player_significance',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The crystals have not sung so clearly since... the last time someone with your particular abilities arrived in our realm. But that was over twenty years ago, and he... well, that is a story for another time.',
          dialogueId: 'player_significance_reveal',
          choices: [
            'What abilities?',
            'Who was he?',
            'Twenty years ago?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_player_special': true,
            'predecessor_mentioned': true,
          },
        ),
        choiceNodeIds: {
          'What abilities?': 'ability_discovery',
          'Who was he?': 'predecessor_story',
          'Twenty years ago?': 'timeline_questions',
        },
      ),
      'fracture_explanation': DialogueNode(
        id: 'fracture_explanation',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Great Fracture was a catastrophic event that shattered the barriers between dimensions. It scattered the Keepers, corrupted entire realms, and created... things that should not exist.',
          dialogueId: 'fracture_basic_explanation',
          choices: [
            'When did this happen?',
            'What kind of things?',
            'Can it happen again?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_fracture_basics': true,
            'corruption_concept_introduced': true,
          },
        ),
        choiceNodeIds: {
          'When did this happen?': 'fracture_timeline',
          'What kind of things?': 'corruption_details',
          'Can it happen again?': 'fracture_prevention',
        },
      ),
      'arrival_mystery': DialogueNode(
        id: 'arrival_mystery',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'That is... concerning. Most who arrive in Luminara do so through the designated portal gates or by airship. To simply "appear" suggests dimensional instability... or intervention.',
          dialogueId: 'arrival_analysis',
          choices: [
            'Intervention by whom?',
            'Is that bad?',
            'I remember a bright light...',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'mysterious_arrival_noted': true,
            'intervention_possibility': true,
          },
        ),
        choiceNodeIds: {
          'Intervention by whom?': 'intervention_theories',
          'Is that bad?': 'arrival_implications',
          'I remember a bright light...': 'light_memory',
        },
      ),
      'ability_discovery': DialogueNode(
        id: 'ability_discovery',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I sense the potential for Aether manipulation within you - the ability to harness dimensional energy directly. Such individuals are rare, and in these troubled times... invaluable.',
          dialogueId: 'ability_identification',
          choices: [
            'How can you tell?',
            'What can I do with these abilities?',
            'Troubled times?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'aether_abilities_confirmed': true,
            'potential_recognized': true,
          },
        ),
        choiceNodeIds: {
          'How can you tell?': 'aether_detection',
          'What can I do with these abilities?': 'ability_applications',
          'Troubled times?': 'current_crisis',
        },
      ),
      'first_quest_offer': DialogueNode(
        id: 'first_quest_offer',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Given your... unique circumstances and evident potential, I have a proposition. Help me with a small matter, and I will begin teaching you to harness your abilities safely.',
          dialogueId: 'initial_quest_offer',
          choices: [
            'What kind of help?',
            'I\'m ready to learn',
            'What\'s the catch?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'first_quest_offered': true,
          },
        ),
        choiceNodeIds: {
          'What kind of help?': 'quest_details',
          'I\'m ready to learn': 'quest_acceptance',
          'What\'s the catch?': 'quest_complications',
        },
      ),
    };
  }

  /// T3.9.3: Context-Sensitive Dialogue Responses
  /// Advanced conversation paths based on player choices and discovered information
  static Map<String, DialogueNode> getMiraContextualResponses() {
    return {
      'luminara_well_significance': DialogueNode(
        id: 'luminara_well_significance',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Luminara Well is the Primary Node - it stabilizes all other Wells in this dimensional cluster. If something were to happen to it... entire realms could collapse into the Void.',
          dialogueId: 'primary_well_importance',
          choices: [
            'That\'s terrifying',
            'Who guards something so important?',
            'Has it ever been threatened?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_well_importance': true,
            'void_threat_understood': true,
          },
        ),
        choiceNodeIds: {
          'That\'s terrifying': 'terror_acknowledgment',
          'Who guards something so important?': 'well_guardians',
          'Has it ever been threatened?': 'well_threats',
        },
      ),
      'keeper_tragedy': DialogueNode(
        id: 'keeper_tragedy',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Fracture... scattered us. Some fell defending the Wells, others were corrupted by dimensional instability. A few simply... vanished. I may be the last true Keeper in this realm.',
          dialogueId: 'keeper_loss_explanation',
          choices: [
            'I\'m sorry for your loss',
            'How do you carry on alone?',
            'Are there Keepers in other realms?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_keeper_tragedy': true,
            'mira_isolation_understood': true,
          },
        ),
        choiceNodeIds: {
          'I\'m sorry for your loss': 'grief_acknowledgment',
          'How do you carry on alone?': 'solitary_burden',
          'Are there Keepers in other realms?': 'other_realm_keepers',
        },
      ),
      'crystal_song_description': DialogueNode(
        id: 'crystal_song_description',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'To me, they whisper of ancient melodies - frequencies that resonate across dimensions. But tonight... tonight they sing of change, of destiny approaching. It is both beautiful and deeply unsettling.',
          dialogueId: 'crystal_song_details',
          choices: [
            'What kind of change?',
            'Do they predict the future?',
            'How long have they been singing?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'crystal_prophecy_hint': true,
            'destiny_concept_introduced': true,
          },
        ),
        choiceNodeIds: {
          'What kind of change?': 'change_nature',
          'Do they predict the future?': 'crystal_prophecy',
          'How long have they been singing?': 'crystal_timing',
        },
      ),
      'quest_details': DialogueNode(
        id: 'quest_details',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Several ancient texts have been scattered throughout Luminara by recent Aether storms. These are not mere books - they contain stabilization formulas crucial for maintaining the Well\'s integrity.',
          dialogueId: 'first_quest_explanation',
          choices: [
            'Where might I find them?',
            'How dangerous is this task?',
            'Why can\'t you retrieve them yourself?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'quest_details_learned': true,
            'text_importance_understood': true,
          },
        ),
        choiceNodeIds: {
          'Where might I find them?': 'text_locations',
          'How dangerous is this task?': 'quest_dangers',
          'Why can\'t you retrieve them yourself?': 'mira_limitations',
        },
      ),
      'quest_acceptance': DialogueNode(
        id: 'quest_acceptance',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Excellent. Your eagerness to help speaks well of your character. Before you begin, let me share some knowledge of Luminara\'s layout and the basics of Aether manipulation.',
          dialogueId: 'quest_accepted_response',
          choices: [
            'Tell me about Luminara\'s districts',
            'Teach me about Aether manipulation',
            'I\'m ready to start immediately',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'first_quest_accepted': true,
            'tutorial_available': true,
          },
          onShowCallbacks: ['increment_counter:quests_accepted'],
        ),
        choiceNodeIds: {
          'Tell me about Luminara\'s districts': 'luminara_districts',
          'Teach me about Aether manipulation': 'aether_tutorial',
          'I\'m ready to start immediately': 'quest_immediate_start',
        },
      ),
      'luminara_districts': DialogueNode(
        id: 'luminara_districts',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Luminara is divided into several key districts: The Spire Plaza at the center, this Archive where we stand, the bustling Market District, and the sacred Aether Well chamber below. Each serves a vital purpose.',
          dialogueId: 'luminara_district_overview',
          choices: [
            'Tell me about the Spire Plaza',
            'What\'s in the Market District?',
            'Can I visit the Aether Well?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'learned_luminara_layout': true,
          },
        ),
        choiceNodeIds: {
          'Tell me about the Spire Plaza': 'spire_plaza_details',
          'What\'s in the Market District?': 'market_district_details',
          'Can I visit the Aether Well?': 'aether_well_access',
        },
      ),
      'spire_plaza_details': DialogueNode(
        id: 'spire_plaza_details',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Spire Plaza is our grand central hub - a crystal fountain marks its heart, surrounded by training grounds and viewing platforms. Many newcomers begin their journey there.',
          dialogueId: 'spire_plaza_description',
          choices: [
            'What kind of training is available?',
            'Are there other newcomers?',
            'What can you see from the viewing platforms?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'What kind of training is available?': 'training_explanation',
          'Are there other newcomers?': 'other_visitors',
          'What can you see from the viewing platforms?': 'plaza_views',
        },
      ),
      'aether_tutorial': DialogueNode(
        id: 'aether_tutorial',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Aether manipulation begins with understanding flow and resonance. Feel the energy around you - it flows like water, but thinks like light. Start with small exercises: reach out with your mind.',
          dialogueId: 'basic_aether_lesson',
          choices: [
            'I can feel something...',
            'This is harder than it looks',
            'What should I be sensing?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'aether_training_started': true,
          },
          onShowCallbacks: ['increment_counter:training_sessions'],
        ),
        choiceNodeIds: {
          'I can feel something...': 'aether_success',
          'This is harder than it looks': 'aether_encouragement',
          'What should I be sensing?': 'aether_guidance',
        },
      ),
      'text_locations': DialogueNode(
        id: 'text_locations',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The Codex of Resonance likely fell near the crystal gardens. The Stability Theorems may have landed in the Market District. As for the Primary Equations... check the highest platforms of the Plaza.',
          dialogueId: 'quest_location_hints',
          choices: [
            'Any other clues to help me find them?',
            'How will I recognize the texts?',
            'Are there any dangers I should know about?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'quest_locations_revealed': true,
          },
        ),
        choiceNodeIds: {
          'Any other clues to help me find them?': 'additional_clues',
          'How will I recognize the texts?': 'text_identification',
          'Are there any dangers I should know about?': 'area_warnings',
        },
      ),
      'observation_discussion': DialogueNode(
        id: 'observation_discussion',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'An observant mind is a scholar\'s greatest tool. Share your thoughts - what has caught your attention during your explorations?',
          dialogueId: 'observation_sharing',
          choices: [
            'The crystals seem to pulse in patterns',
            'Some areas feel unstable somehow',
            'I\'ve seen strange shadows moving',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'The crystals seem to pulse in patterns': 'crystal_patterns',
          'Some areas feel unstable somehow': 'instability_discussion',
          'I\'ve seen strange shadows moving': 'shadow_concerns',
        },
      ),
      'advanced_training': DialogueNode(
        id: 'advanced_training',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'You are ready for more advanced techniques. Let us explore dimensional sight - the ability to perceive Aether currents directly. This skill will serve you well in the trials ahead.',
          dialogueId: 'advanced_lesson_intro',
          choices: [
            'I\'m ready to learn',
            'What trials do you mean?',
            'How dangerous is dimensional sight?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'counter_greater_than': {'counter': 'training_sessions', 'value': 3},
        },
        choiceNodeIds: {
          'I\'m ready to learn': 'dimensional_sight_lesson',
          'What trials do you mean?': 'future_challenges',
          'How dangerous is dimensional sight?': 'sight_warnings',
        },
      ),
      'luminara_history': DialogueNode(
        id: 'luminara_history',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Luminara was built during the Age of Harmony, when the Keepers first discovered this Primary Well. The city grew organically around the crystal formations, each district shaped by the Aether currents beneath.',
          dialogueId: 'luminara_founding_story',
          choices: [
            'Who built the original structures?',
            'How long has it been floating?',
            'What was here before the city?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Who built the original structures?': 'original_builders',
          'How long has it been floating?': 'floating_duration',
          'What was here before the city?': 'pre_city_history',
        },
      ),
      'keeper_training_offer': DialogueNode(
        id: 'keeper_training_offer',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'The path of a Keeper is not chosen lightly. It requires dedication, sacrifice, and the willingness to put the welfare of all realms before personal desires. If you truly wish this... we can begin the formal trials.',
          dialogueId: 'keeper_path_offer',
          choices: [
            'I accept the responsibility',
            'What would the trials involve?',
            'I need time to consider this',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'keeper_path_offered': true,
          },
        ),
        choiceNodeIds: {
          'I accept the responsibility': 'keeper_trials_begin',
          'What would the trials involve?': 'trial_explanation',
          'I need time to consider this': 'consideration_time',
        },
      ),
    };
  }

  /// T3.9.4: Ongoing Conversation Options
  /// Dialogue trees for subsequent conversations with Mira
  static Map<String, DialogueNode> getMiraOngoingConversations() {
    return {
      'returning_visitor': DialogueNode(
        id: 'returning_visitor',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Welcome back to the Archive. I trust your exploration of Luminara has been... enlightening?',
          dialogueId: 'mira_return_greeting',
          choices: [
            'I have questions about what I\'ve seen',
            'I found something interesting',
            'Can you teach me more?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'flag_equals_met_mira': {'flag': 'met_mira', 'value': true},
          'flag_equals_first_meeting': {
            'flag': 'first_meeting_complete',
            'value': true
          },
        },
        choiceNodeIds: {
          'I have questions about what I\'ve seen': 'observation_discussion',
          'I found something interesting': 'discovery_sharing',
          'Can you teach me more?': 'advanced_lessons',
        },
      ),
      'progress_check': DialogueNode(
        id: 'progress_check',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'I can sense your abilities growing stronger. The crystals sing more harmoniously in your presence now. You are making remarkable progress.',
          dialogueId: 'progress_acknowledgment',
          choices: [
            'What comes next in my training?',
            'I feel different lately',
            'The crystals seem more responsive',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'counter_greater_than': {'counter': 'texts_found', 'value': 2},
        },
        choiceNodeIds: {
          'What comes next in my training?': 'advanced_training',
          'I feel different lately': 'transformation_discussion',
          'The crystals seem more responsive': 'crystal_bond_development',
        },
      ),
      'lore_keeper': DialogueNode(
        id: 'lore_keeper',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'Ah, seeking knowledge again? The Archive holds many secrets. What aspect of our realm\'s history intrigues you today?',
          dialogueId: 'lore_discussion_prompt',
          choices: [
            'Tell me about the founding of Luminara',
            'What was life like before the Fracture?',
            'Are there other beings like me?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Tell me about the founding of Luminara': 'luminara_history',
          'What was life like before the Fracture?': 'pre_fracture_life',
          'Are there other beings like me?': 'other_travelers',
        },
        cooldownSeconds: 3600, // 1 hour cooldown for lore discussions
      ),
      'mentor_relationship': DialogueNode(
        id: 'mentor_relationship',
        entry: DialogueEntry(
          speakerName: 'Mira',
          text:
              'You have become dear to me, young one. In you, I see hope for our realm\'s future. The burden of the Keepers need not rest on my shoulders alone.',
          dialogueId: 'mentor_bond_acknowledgment',
          choices: [
            'I\'m honored by your trust',
            'Will you teach me to be a Keeper?',
            'What does the future hold?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'counter_greater_than': {
            'counter': 'conversation_count',
            'value': 10
          },
          'flag_equals': {'flag': 'first_quest_completed', 'value': true},
        },
        choiceNodeIds: {
          'I\'m honored by your trust': 'trust_reciprocation',
          'Will you teach me to be a Keeper?': 'keeper_training_offer',
          'What does the future hold?': 'future_visions',
        },
      ),
    };
  }

  /// Quick test conversation for demonstrating features
  static List<DialogueEntry> getTestConversation() {
    return [
      DialogueEntry(
        speakerName: 'Test NPC',
        text:
            'Hello! This is a test of the typewriter effect with punctuation pauses.',
        dialogueId: 'test_1',
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
      DialogueEntry(
        speakerName: 'Test NPC',
        text: 'This message appears instantly without typewriter effect.',
        dialogueId: 'test_2',
        useTypewriter: false,
        pauseAfterPunctuation: false,
      ),
      DialogueEntry(
        speakerName: 'Test NPC',
        text: 'Here\'s a choice for you to make!',
        dialogueId: 'test_3',
        choices: ['Option A', 'Option B', 'Option C'],
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
    ];
  }

  /// Conversation with auto-advance timing
  static List<DialogueEntry> getTimedConversation() {
    return [
      DialogueEntry(
        speakerName: 'Narrator',
        text: 'This message will advance automatically after 3 seconds...',
        dialogueId: 'timed_1',
        displayDuration: 3.0,
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
      DialogueEntry(
        speakerName: 'Narrator',
        text: 'And this one after 2 seconds...',
        dialogueId: 'timed_2',
        displayDuration: 2.0,
        useTypewriter: true,
        pauseAfterPunctuation: false,
      ),
      DialogueEntry(
        speakerName: 'Narrator',
        text: 'This final message requires manual advancement.',
        dialogueId: 'timed_3',
        useTypewriter: true,
        pauseAfterPunctuation: true,
      ),
    ];
  }

  /// Complex conversation tree with conditional branches
  static Map<String, DialogueNode> getComplexConversationTree() {
    return {
      'complex_start': DialogueNode(
        id: 'complex_start',
        entry: DialogueEntry(
          speakerName: 'Elder Sage',
          text:
              'Welcome, traveler. Your journey has been long, but your destination is finally within reach.',
          dialogueId: 'complex_start',
          choices: [
            'Who are you?',
            'What destination?',
            'I\'m just passing through',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Who are you?': 'sage_identity',
          'What destination?': 'destiny_path',
          'I\'m just passing through': 'dismissive_response',
        },
      ),
      'sage_identity': DialogueNode(
        id: 'sage_identity',
        entry: DialogueEntry(
          speakerName: 'Elder Sage',
          text:
              'I am but a humble keeper of ancient wisdom, one who has watched the turning of ages and the rise and fall of countless civilizations.',
          dialogueId: 'sage_identity',
          choices: [
            'How old are you?',
            'What have you seen?',
            'That\'s incredible',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'How old are you?': 'sage_age',
          'What have you seen?': 'sage_visions',
          'That\'s incredible': 'sage_modest',
        },
      ),
      'destiny_path': DialogueNode(
        id: 'destiny_path',
        entry: DialogueEntry(
          speakerName: 'Elder Sage',
          text:
              'Your destiny lies beyond the Shimmering Veil, where the boundaries between worlds grow thin. Few have the strength to walk that path.',
          dialogueId: 'destiny_path',
          choices: [
            'I don\'t believe in destiny',
            'Tell me more about this path',
            'Am I strong enough?',
          ],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'I don\'t believe in destiny': 'destiny_skeptic',
          'Tell me more about this path': 'path_details',
          'Am I strong enough?': 'strength_assessment',
        },
      ),
    };
  }

  /// Conversation tree with cooldown mechanics
  static Map<String, DialogueNode> getCooldownConversationTree() {
    return {
      'daily_greeting': DialogueNode(
        id: 'daily_greeting',
        entry: DialogueEntry(
          speakerName: 'Shopkeeper',
          text: 'Good day! Welcome to my shop. How can I help you today?',
          dialogueId: 'shop_daily_greeting',
          choices: ['Show me your wares', 'Just browsing', 'Goodbye'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {
            'last_shop_visit': {'operation': 'set', 'value': 'today'},
          },
        ),
        choiceNodeIds: {
          'Show me your wares': 'shop_inventory',
          'Just browsing': 'shop_browse',
          'Goodbye': 'shop_farewell',
        },
        cooldownSeconds: 86400, // 24 hours
        maxVisits: 1,
      ),
      'returning_customer': DialogueNode(
        id: 'returning_customer',
        entry: DialogueEntry(
          speakerName: 'Shopkeeper',
          text: 'Ah, you\'re back! Always good to see a returning customer.',
          dialogueId: 'shop_returning_customer',
          choices: ['Show me your wares', 'Any new items?', 'Goodbye'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'flag_exists': 'last_shop_visit',
        },
        choiceNodeIds: {
          'Show me your wares': 'shop_inventory',
          'Any new items?': 'shop_new_items',
          'Goodbye': 'shop_farewell',
        },
      ),
    };
  }

  /// Conversation tree for testing condition evaluation
  static Map<String, DialogueNode> getConditionalTestTree() {
    return {
      'test_start': DialogueNode(
        id: 'test_start',
        entry: DialogueEntry(
          speakerName: 'Test NPC',
          text: 'Let\'s test various dialogue conditions!',
          dialogueId: 'test_conditions_start',
          choices: ['Set flag', 'Increment counter', 'Check conditions'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        choiceNodeIds: {
          'Set flag': 'set_flag_node',
          'Increment counter': 'increment_counter_node',
          'Check conditions': 'check_conditions_node',
        },
      ),
      'set_flag_node': DialogueNode(
        id: 'set_flag_node',
        entry: DialogueEntry(
          speakerName: 'Test NPC',
          text: 'Flag has been set! You can now access conditional content.',
          dialogueId: 'test_flag_set',
          choices: ['Back to start'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
          stateChanges: {'test_flag': true},
          onShowCallbacks: ['set_flag:test_flag:true'],
        ),
        choiceNodeIds: {
          'Back to start': 'test_start',
        },
      ),
      'conditional_content': DialogueNode(
        id: 'conditional_content',
        entry: DialogueEntry(
          speakerName: 'Test NPC',
          text: 'This message only appears if the test flag is set!',
          dialogueId: 'test_conditional_content',
          choices: ['Amazing!', 'Reset flag'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        ),
        conditions: {
          'flag_equals': {'flag': 'test_flag', 'value': true},
        },
        choiceNodeIds: {
          'Amazing!': 'test_start',
          'Reset flag': 'reset_flag_node',
        },
      ),
    };
  }
}
