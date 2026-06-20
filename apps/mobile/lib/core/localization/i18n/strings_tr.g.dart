///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsTr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsTr _root = this; // ignore: unused_field

	@override 
	TranslationsTr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$tr common = _Translations$common$tr._(_root);
	@override late final _Translations$login$tr login = _Translations$login$tr._(_root);
	@override late final _Translations$register$tr register = _Translations$register$tr._(_root);
	@override late final _Translations$favorites$tr favorites = _Translations$favorites$tr._(_root);
	@override late final _Translations$pokemon$tr pokemon = _Translations$pokemon$tr._(_root);
}

// Path: common
class _Translations$common$tr implements Translations$common$en {
	_Translations$common$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get ok => 'Tamam';
	@override String get cancel => 'İptal';
	@override String get retry => 'Tekrar Dene';
	@override String get unknown => 'Bilinmiyor';
}

// Path: login
class _Translations$login$tr implements Translations$login$en {
	_Translations$login$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Base Project';
	@override String get subtitle => 'Clean Architecture · Monorepo';
	@override String get title => 'Giriş Yap';
	@override String get emailLabel => 'E-posta';
	@override String get emailHint => 'ornek@posta.com';
	@override String get passwordLabel => 'Şifre';
	@override String get passwordHint => '••••••••';
	@override String get submitButton => 'Giriş Yap';
	@override String get demoButton => 'Demo Hesabı Doldur';
	@override String get orDivider => 'veya';
	@override String get googleTooltip => 'Google ile Giriş';
	@override String get appleTooltip => 'Apple ile Giriş';
	@override String get noAccount => 'Hesabınız yok mu? ';
	@override String get registerLink => 'Kayıt Ol';
}

// Path: register
class _Translations$register$tr implements Translations$register$en {
	_Translations$register$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kayıt Ol';
	@override String get subtitle => 'Yeni bir profil oluşturun';
	@override String get backTooltip => 'Giriş Yap\'a dön';
	@override String get firstNameLabel => 'Ad';
	@override String get firstNameHint => 'Adınız';
	@override String get lastNameLabel => 'Soyad';
	@override String get lastNameHint => 'Soyadınız';
	@override String get emailLabel => 'E-posta';
	@override String get emailHint => 'ornek@posta.com';
	@override String get passwordLabel => 'Şifre';
	@override String get passwordHint => '••••••••';
	@override String get submitButton => 'Hesap Oluştur';
	@override String get hasAccount => 'Zaten hesabınız var mı? ';
	@override String get loginLink => 'Giriş Yap';
}

// Path: favorites
class _Translations$favorites$tr implements Translations$favorites$en {
	_Translations$favorites$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Favorilerim';
	@override String get clearTooltip => 'Tümünü Temizle';
	@override String get clearTitle => 'Favorileri Temizle?';
	@override String get clearConfirm => 'Tüm favori Pokemonları kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.';
	@override String get clearButton => 'Tümünü Sil';
	@override String get clearSuccess => 'Tüm favoriler temizlendi';
	@override String get removeTitle => 'Favorilerden Kaldır?';
	@override String removeConfirm({required Object name}) => '${name} favorilerinizden kaldırılsın mı?';
	@override String get removeButton => 'Kaldır';
	@override String removeSuccess({required Object name}) => '${name} favorilerden kaldırıldı';
	@override String get removeTooltip => 'Favorilerden Çıkar';
	@override String get emptyPokemon => 'Henüz favori Pokemon yok';
	@override String get emptyPokemonHint => 'Pokemon sekmesinden ❤ ile ekleyebilirsin';
}

// Path: pokemon
class _Translations$pokemon$tr implements Translations$pokemon$en {
	_Translations$pokemon$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get searchHint => 'Pokémon Ara...';
	@override late final _Translations$pokemon$detail$tr detail = _Translations$pokemon$detail$tr._(_root);
}

// Path: pokemon.detail
class _Translations$pokemon$detail$tr implements Translations$pokemon$detail$en {
	_Translations$pokemon$detail$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get error => 'Hata';
	@override late final _Translations$pokemon$detail$tabs$tr tabs = _Translations$pokemon$detail$tabs$tr._(_root);
	@override late final _Translations$pokemon$detail$about$tr about = _Translations$pokemon$detail$about$tr._(_root);
	@override late final _Translations$pokemon$detail$stats$tr stats = _Translations$pokemon$detail$stats$tr._(_root);
	@override late final _Translations$pokemon$detail$evolution$tr evolution = _Translations$pokemon$detail$evolution$tr._(_root);
	@override late final _Translations$pokemon$detail$moves$tr moves = _Translations$pokemon$detail$moves$tr._(_root);
}

// Path: pokemon.detail.tabs
class _Translations$pokemon$detail$tabs$tr implements Translations$pokemon$detail$tabs$en {
	_Translations$pokemon$detail$tabs$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get about => 'Hakkında';
	@override String get stats => 'Statlar';
	@override String get evolution => 'Evrim';
	@override String get moves => 'Hamleler';
}

// Path: pokemon.detail.about
class _Translations$pokemon$detail$about$tr implements Translations$pokemon$detail$about$en {
	_Translations$pokemon$detail$about$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get species => 'Tür';
	@override String get height => 'Boy';
	@override String get weight => 'Kilo';
	@override String get abilities => 'Yetenekler';
	@override String get habitat => 'Habitat';
	@override String get breeding => 'Üreme';
	@override String get eggGroups => 'Yumurta Grupları';
	@override String get gender => 'Cinsiyet';
	@override String get genderless => 'Cinsiyetsiz';
}

// Path: pokemon.detail.stats
class _Translations$pokemon$detail$stats$tr implements Translations$pokemon$detail$stats$en {
	_Translations$pokemon$detail$stats$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Temel İstatistikler';
	@override String get total => 'Toplam';
	@override String get hp => 'HP';
	@override String get attack => 'Saldırı';
	@override String get defense => 'Savunma';
	@override String get spAttack => 'Öz. Saldırı';
	@override String get spDefense => 'Öz. Savunma';
	@override String get speed => 'Hız';
}

// Path: pokemon.detail.evolution
class _Translations$pokemon$detail$evolution$tr implements Translations$pokemon$detail$evolution$en {
	_Translations$pokemon$detail$evolution$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get noData => 'Evrim verisi bulunamadı';
	@override String get chainTitle => 'Evrim Zinciri';
}

// Path: pokemon.detail.moves
class _Translations$pokemon$detail$moves$tr implements Translations$pokemon$detail$moves$en {
	_Translations$pokemon$detail$moves$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String learnMethod({required Object method}) => 'Öğrenme yöntemi: ${method}';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.ok' => 'Tamam',
			'common.cancel' => 'İptal',
			'common.retry' => 'Tekrar Dene',
			'common.unknown' => 'Bilinmiyor',
			'login.appName' => 'Base Project',
			'login.subtitle' => 'Clean Architecture · Monorepo',
			'login.title' => 'Giriş Yap',
			'login.emailLabel' => 'E-posta',
			'login.emailHint' => 'ornek@posta.com',
			'login.passwordLabel' => 'Şifre',
			'login.passwordHint' => '••••••••',
			'login.submitButton' => 'Giriş Yap',
			'login.demoButton' => 'Demo Hesabı Doldur',
			'login.orDivider' => 'veya',
			'login.googleTooltip' => 'Google ile Giriş',
			'login.appleTooltip' => 'Apple ile Giriş',
			'login.noAccount' => 'Hesabınız yok mu? ',
			'login.registerLink' => 'Kayıt Ol',
			'register.title' => 'Kayıt Ol',
			'register.subtitle' => 'Yeni bir profil oluşturun',
			'register.backTooltip' => 'Giriş Yap\'a dön',
			'register.firstNameLabel' => 'Ad',
			'register.firstNameHint' => 'Adınız',
			'register.lastNameLabel' => 'Soyad',
			'register.lastNameHint' => 'Soyadınız',
			'register.emailLabel' => 'E-posta',
			'register.emailHint' => 'ornek@posta.com',
			'register.passwordLabel' => 'Şifre',
			'register.passwordHint' => '••••••••',
			'register.submitButton' => 'Hesap Oluştur',
			'register.hasAccount' => 'Zaten hesabınız var mı? ',
			'register.loginLink' => 'Giriş Yap',
			'favorites.title' => 'Favorilerim',
			'favorites.clearTooltip' => 'Tümünü Temizle',
			'favorites.clearTitle' => 'Favorileri Temizle?',
			'favorites.clearConfirm' => 'Tüm favori Pokemonları kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
			'favorites.clearButton' => 'Tümünü Sil',
			'favorites.clearSuccess' => 'Tüm favoriler temizlendi',
			'favorites.removeTitle' => 'Favorilerden Kaldır?',
			'favorites.removeConfirm' => ({required Object name}) => '${name} favorilerinizden kaldırılsın mı?',
			'favorites.removeButton' => 'Kaldır',
			'favorites.removeSuccess' => ({required Object name}) => '${name} favorilerden kaldırıldı',
			'favorites.removeTooltip' => 'Favorilerden Çıkar',
			'favorites.emptyPokemon' => 'Henüz favori Pokemon yok',
			'favorites.emptyPokemonHint' => 'Pokemon sekmesinden ❤ ile ekleyebilirsin',
			'pokemon.searchHint' => 'Pokémon Ara...',
			'pokemon.detail.error' => 'Hata',
			'pokemon.detail.tabs.about' => 'Hakkında',
			'pokemon.detail.tabs.stats' => 'Statlar',
			'pokemon.detail.tabs.evolution' => 'Evrim',
			'pokemon.detail.tabs.moves' => 'Hamleler',
			'pokemon.detail.about.species' => 'Tür',
			'pokemon.detail.about.height' => 'Boy',
			'pokemon.detail.about.weight' => 'Kilo',
			'pokemon.detail.about.abilities' => 'Yetenekler',
			'pokemon.detail.about.habitat' => 'Habitat',
			'pokemon.detail.about.breeding' => 'Üreme',
			'pokemon.detail.about.eggGroups' => 'Yumurta Grupları',
			'pokemon.detail.about.gender' => 'Cinsiyet',
			'pokemon.detail.about.genderless' => 'Cinsiyetsiz',
			'pokemon.detail.stats.title' => 'Temel İstatistikler',
			'pokemon.detail.stats.total' => 'Toplam',
			'pokemon.detail.stats.hp' => 'HP',
			'pokemon.detail.stats.attack' => 'Saldırı',
			'pokemon.detail.stats.defense' => 'Savunma',
			'pokemon.detail.stats.spAttack' => 'Öz. Saldırı',
			'pokemon.detail.stats.spDefense' => 'Öz. Savunma',
			'pokemon.detail.stats.speed' => 'Hız',
			'pokemon.detail.evolution.noData' => 'Evrim verisi bulunamadı',
			'pokemon.detail.evolution.chainTitle' => 'Evrim Zinciri',
			'pokemon.detail.moves.learnMethod' => ({required Object method}) => 'Öğrenme yöntemi: ${method}',
			_ => null,
		};
	}
}
