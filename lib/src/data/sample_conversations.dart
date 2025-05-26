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
          'Just exploring'
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
            'That sounds fascinating'
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
            'Amazing...'
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
            'Tell me more about dimensions'
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
            'Sounds dangerous'
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
            'Thank you'
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
            'I\'m just passing through'
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
            'That\'s incredible'
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
            'Am I strong enough?'
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
}
