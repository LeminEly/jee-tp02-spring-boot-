package com.ioc.springcoredemo.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.BeanFactoryAnnotationUtils;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Exercice 5.3 : ce que le qualifier garantit vraiment.
 *
 * <p>Le test porte sur le conteneur, pas sur le texte renvoye par le point
 * d'acces : ce texte changera a l'exercice 5.8, alors que la regle du qualifier,
 * elle, ne change pas. Un test qui casserait a chaque exercice ne protegerait
 * rien.
 */
@SpringBootTest
class QualifierSelectionTest {

	@Autowired
	private ApplicationContext conteneur;

	@Test
	void leQualifierDesigneExactementLeBeanNomme() {
		assertThat(coachQualifie("cricketCoach")).isInstanceOf(CricketCoach.class);
		assertThat(coachQualifie("tennisCoach")).isInstanceOf(TennisCoach.class);
		assertThat(coachQualifie("trackCoach")).isInstanceOf(TrackCoach.class);
		assertThat(coachQualifie("baseballCoach")).isInstanceOf(BaseballCoach.class);
	}

	@Test
	void lIdParDefautEstLeNomDeClasseAPremiereLettreMinuscule() {
		assertThat(conteneur.getBeanNamesForType(Coach.class))
				.contains("cricketCoach", "baseballCoach", "tennisCoach", "trackCoach");
	}

	private Coach coachQualifie(String identifiant) {
		return BeanFactoryAnnotationUtils.qualifiedBeanOfType(conteneur, Coach.class, identifiant);
	}

}
