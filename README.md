# senscritique-fix-movie-release-dates
[![travis-build-status](https://travis-ci.org/vincent-clipet/senscritique-fix-movie-release-dates.svg?branch=master)](https://travis-ci.org/vincent-clipet/senscritique-fix-movie-release-dates)




Description
===========

Script pour ajouter/corriger les dates de sortie internationale & française sur la page [SensCritique](https://senscritique.com) d'un film.

Les données de référence sont récupérées depuis [IMDB](http://imdb.com/).





Dépendances
===========

* Ruby 2.0 ou +
* [nokogiri](https://github.com/sparklemotion/nokogiri)
* [mechanize](https://github.com/sparklemotion/mechanize)
* [rest-client](https://github.com/rest-client/rest-client)





Configuration
=============

* Renommer le fichier ```config/config.rb.example``` en ```config/config.rb```
* Modifier la valeur de *"SC_AUTH"* avec votre cookie d'authentification





Utilisation
===========

```
ruby senscritique-fix-movie-release-dates.rb [url_film_senscritique]
```

Exemple :
```
ruby senscritique-fix-movie-release-dates.rb https://www.senscritique.com/film/Fight_Club/363185
```





Améliorations
=============

* Ne plus utiliser *rest-client*, Mechanize pourrait directement gérer les HTTP GET initiaux vers les 2 sites