package com.ioc.springcoredemo.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Exercice 5.6 : ce que change la portee d'un bean.
 *
 * <p>Le point d'acces {@code /check} montre la meme chose a l'ecran. Ce test la
 * fige, et surtout il garde les deux portees cote a cote : le depot ne peut en
 * porter qu'une a la fois, puisque l'exercice 5.7 exige le singleton.
 */
class BeanScopeTest {

	private final ApplicationContextRunner conteneur = new ApplicationContextRunner();

	@Test
	void unSingletonEstPartageEntreTousSesPointsDInjection() {
		conteneur.withUserConfiguration(PorteeSingleton.class).run(contexte -> {
			Coach premier = contexte.getBean("coach", Coach.class);
			Coach second = contexte.getBean("coach", Coach.class);
			assertThat(premier).isSameAs(second);
		});
	}

	@Test
	void unPrototypeDonneUneInstanceNeuveAChaqueDemande() {
		conteneur.withUserConfiguration(PorteePrototype.class).run(contexte -> {
			Coach premier = contexte.getBean("coach", Coach.class);
			Coach second = contexte.getBean("coach", Coach.class);
			assertThat(premier).isNotSameAs(second);
		});
	}

	@Configuration(proxyBeanMethods = false)
	static class PorteeSingleton {

		@Bean
		Coach coach() {
			return new CricketCoach();
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class PorteePrototype {

		@Bean
		@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
		Coach coach() {
			return new CricketCoach();
		}

	}

}
