///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$login$en login = Translations$login$en._(_root);
	late final Translations$register$en register = Translations$register$en._(_root);
	late final Translations$favorites$en favorites = Translations$favorites$en._(_root);
	late final Translations$pokemon$en pokemon = Translations$pokemon$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Try Again'
	String get retry => 'Try Again';

	/// en: 'Unknown'
	String get unknown => 'Unknown';
}

// Path: login
class Translations$login$en {
	Translations$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Base Project'
	String get appName => 'Base Project';

	/// en: 'Clean Architecture · Monorepo'
	String get subtitle => 'Clean Architecture · Monorepo';

	/// en: 'Sign In'
	String get title => 'Sign In';

	/// en: 'Email'
	String get emailLabel => 'Email';

	/// en: 'example@email.com'
	String get emailHint => 'example@email.com';

	/// en: 'Password'
	String get passwordLabel => 'Password';

	/// en: '••••••••'
	String get passwordHint => '••••••••';

	/// en: 'Sign In'
	String get submitButton => 'Sign In';

	/// en: 'Fill Demo Account'
	String get demoButton => 'Fill Demo Account';

	/// en: 'or'
	String get orDivider => 'or';

	/// en: 'Sign In with Google'
	String get googleTooltip => 'Sign In with Google';

	/// en: 'Sign In with Apple'
	String get appleTooltip => 'Sign In with Apple';

	/// en: 'Don't have an account? '
	String get noAccount => 'Don\'t have an account? ';

	/// en: 'Sign Up'
	String get registerLink => 'Sign Up';
}

// Path: register
class Translations$register$en {
	Translations$register$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign Up'
	String get title => 'Sign Up';

	/// en: 'Create a new profile'
	String get subtitle => 'Create a new profile';

	/// en: 'Back to Sign In'
	String get backTooltip => 'Back to Sign In';

	/// en: 'First Name'
	String get firstNameLabel => 'First Name';

	/// en: 'Your First Name'
	String get firstNameHint => 'Your First Name';

	/// en: 'Last Name'
	String get lastNameLabel => 'Last Name';

	/// en: 'Your Last Name'
	String get lastNameHint => 'Your Last Name';

	/// en: 'Email'
	String get emailLabel => 'Email';

	/// en: 'example@email.com'
	String get emailHint => 'example@email.com';

	/// en: 'Password'
	String get passwordLabel => 'Password';

	/// en: '••••••••'
	String get passwordHint => '••••••••';

	/// en: 'Create Account'
	String get submitButton => 'Create Account';

	/// en: 'Already have an account? '
	String get hasAccount => 'Already have an account? ';

	/// en: 'Sign In'
	String get loginLink => 'Sign In';
}

// Path: favorites
class Translations$favorites$en {
	Translations$favorites$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Favorites'
	String get title => 'My Favorites';

	/// en: 'Clear All'
	String get clearTooltip => 'Clear All';

	/// en: 'Clear Favorites?'
	String get clearTitle => 'Clear Favorites?';

	/// en: 'Are you sure you want to remove all favorite Pokémon? This action cannot be undone.'
	String get clearConfirm => 'Are you sure you want to remove all favorite Pokémon? This action cannot be undone.';

	/// en: 'Delete All'
	String get clearButton => 'Delete All';

	/// en: 'All favorites cleared'
	String get clearSuccess => 'All favorites cleared';

	/// en: 'Remove from Favorites?'
	String get removeTitle => 'Remove from Favorites?';

	/// en: 'Remove {name} from your favorites?'
	String removeConfirm({required Object name}) => 'Remove ${name} from your favorites?';

	/// en: 'Remove'
	String get removeButton => 'Remove';

	/// en: '{name} removed from favorites'
	String removeSuccess({required Object name}) => '${name} removed from favorites';

	/// en: 'Remove from Favorites'
	String get removeTooltip => 'Remove from Favorites';

	/// en: 'No favorite Pokémon yet'
	String get emptyPokemon => 'No favorite Pokémon yet';

	/// en: 'Add Pokémon with ❤ from the Pokémon tab'
	String get emptyPokemonHint => 'Add Pokémon with ❤ from the Pokémon tab';
}

// Path: pokemon
class Translations$pokemon$en {
	Translations$pokemon$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search Pokémon...'
	String get searchHint => 'Search Pokémon...';

	late final Translations$pokemon$detail$en detail = Translations$pokemon$detail$en._(_root);
}

// Path: pokemon.detail
class Translations$pokemon$detail$en {
	Translations$pokemon$detail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get error => 'Error';

	late final Translations$pokemon$detail$tabs$en tabs = Translations$pokemon$detail$tabs$en._(_root);
	late final Translations$pokemon$detail$about$en about = Translations$pokemon$detail$about$en._(_root);
	late final Translations$pokemon$detail$stats$en stats = Translations$pokemon$detail$stats$en._(_root);
	late final Translations$pokemon$detail$evolution$en evolution = Translations$pokemon$detail$evolution$en._(_root);
	late final Translations$pokemon$detail$moves$en moves = Translations$pokemon$detail$moves$en._(_root);
}

// Path: pokemon.detail.tabs
class Translations$pokemon$detail$tabs$en {
	Translations$pokemon$detail$tabs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About'
	String get about => 'About';

	/// en: 'Stats'
	String get stats => 'Stats';

	/// en: 'Evolution'
	String get evolution => 'Evolution';

	/// en: 'Moves'
	String get moves => 'Moves';
}

// Path: pokemon.detail.about
class Translations$pokemon$detail$about$en {
	Translations$pokemon$detail$about$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Species'
	String get species => 'Species';

	/// en: 'Height'
	String get height => 'Height';

	/// en: 'Weight'
	String get weight => 'Weight';

	/// en: 'Abilities'
	String get abilities => 'Abilities';

	/// en: 'Habitat'
	String get habitat => 'Habitat';

	/// en: 'Breeding'
	String get breeding => 'Breeding';

	/// en: 'Egg Groups'
	String get eggGroups => 'Egg Groups';

	/// en: 'Gender'
	String get gender => 'Gender';

	/// en: 'Genderless'
	String get genderless => 'Genderless';
}

// Path: pokemon.detail.stats
class Translations$pokemon$detail$stats$en {
	Translations$pokemon$detail$stats$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Base Stats'
	String get title => 'Base Stats';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'HP'
	String get hp => 'HP';

	/// en: 'Attack'
	String get attack => 'Attack';

	/// en: 'Defense'
	String get defense => 'Defense';

	/// en: 'Sp. Attack'
	String get spAttack => 'Sp. Attack';

	/// en: 'Sp. Defense'
	String get spDefense => 'Sp. Defense';

	/// en: 'Speed'
	String get speed => 'Speed';
}

// Path: pokemon.detail.evolution
class Translations$pokemon$detail$evolution$en {
	Translations$pokemon$detail$evolution$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No evolution data found'
	String get noData => 'No evolution data found';

	/// en: 'Evolution Chain'
	String get chainTitle => 'Evolution Chain';
}

// Path: pokemon.detail.moves
class Translations$pokemon$detail$moves$en {
	Translations$pokemon$detail$moves$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Learn method: {method}'
	String learnMethod({required Object method}) => 'Learn method: ${method}';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.ok' => 'OK',
			'common.cancel' => 'Cancel',
			'common.retry' => 'Try Again',
			'common.unknown' => 'Unknown',
			'login.appName' => 'Base Project',
			'login.subtitle' => 'Clean Architecture · Monorepo',
			'login.title' => 'Sign In',
			'login.emailLabel' => 'Email',
			'login.emailHint' => 'example@email.com',
			'login.passwordLabel' => 'Password',
			'login.passwordHint' => '••••••••',
			'login.submitButton' => 'Sign In',
			'login.demoButton' => 'Fill Demo Account',
			'login.orDivider' => 'or',
			'login.googleTooltip' => 'Sign In with Google',
			'login.appleTooltip' => 'Sign In with Apple',
			'login.noAccount' => 'Don\'t have an account? ',
			'login.registerLink' => 'Sign Up',
			'register.title' => 'Sign Up',
			'register.subtitle' => 'Create a new profile',
			'register.backTooltip' => 'Back to Sign In',
			'register.firstNameLabel' => 'First Name',
			'register.firstNameHint' => 'Your First Name',
			'register.lastNameLabel' => 'Last Name',
			'register.lastNameHint' => 'Your Last Name',
			'register.emailLabel' => 'Email',
			'register.emailHint' => 'example@email.com',
			'register.passwordLabel' => 'Password',
			'register.passwordHint' => '••••••••',
			'register.submitButton' => 'Create Account',
			'register.hasAccount' => 'Already have an account? ',
			'register.loginLink' => 'Sign In',
			'favorites.title' => 'My Favorites',
			'favorites.clearTooltip' => 'Clear All',
			'favorites.clearTitle' => 'Clear Favorites?',
			'favorites.clearConfirm' => 'Are you sure you want to remove all favorite Pokémon? This action cannot be undone.',
			'favorites.clearButton' => 'Delete All',
			'favorites.clearSuccess' => 'All favorites cleared',
			'favorites.removeTitle' => 'Remove from Favorites?',
			'favorites.removeConfirm' => ({required Object name}) => 'Remove ${name} from your favorites?',
			'favorites.removeButton' => 'Remove',
			'favorites.removeSuccess' => ({required Object name}) => '${name} removed from favorites',
			'favorites.removeTooltip' => 'Remove from Favorites',
			'favorites.emptyPokemon' => 'No favorite Pokémon yet',
			'favorites.emptyPokemonHint' => 'Add Pokémon with ❤ from the Pokémon tab',
			'pokemon.searchHint' => 'Search Pokémon...',
			'pokemon.detail.error' => 'Error',
			'pokemon.detail.tabs.about' => 'About',
			'pokemon.detail.tabs.stats' => 'Stats',
			'pokemon.detail.tabs.evolution' => 'Evolution',
			'pokemon.detail.tabs.moves' => 'Moves',
			'pokemon.detail.about.species' => 'Species',
			'pokemon.detail.about.height' => 'Height',
			'pokemon.detail.about.weight' => 'Weight',
			'pokemon.detail.about.abilities' => 'Abilities',
			'pokemon.detail.about.habitat' => 'Habitat',
			'pokemon.detail.about.breeding' => 'Breeding',
			'pokemon.detail.about.eggGroups' => 'Egg Groups',
			'pokemon.detail.about.gender' => 'Gender',
			'pokemon.detail.about.genderless' => 'Genderless',
			'pokemon.detail.stats.title' => 'Base Stats',
			'pokemon.detail.stats.total' => 'Total',
			'pokemon.detail.stats.hp' => 'HP',
			'pokemon.detail.stats.attack' => 'Attack',
			'pokemon.detail.stats.defense' => 'Defense',
			'pokemon.detail.stats.spAttack' => 'Sp. Attack',
			'pokemon.detail.stats.spDefense' => 'Sp. Defense',
			'pokemon.detail.stats.speed' => 'Speed',
			'pokemon.detail.evolution.noData' => 'No evolution data found',
			'pokemon.detail.evolution.chainTitle' => 'Evolution Chain',
			'pokemon.detail.moves.learnMethod' => ({required Object method}) => 'Learn method: ${method}',
			_ => null,
		};
	}
}
