# Orientação a Objetos (OOP)

## Classe e Objeto
```java
class Pessoa {
  String nome;
  int idade;

  void apresentar() {
    System.out.println("Sou " + nome + ", tenho " + idade);
  }
}

public class Main {
  public static void main(String[] args) {
    Pessoa p = new Pessoa();
    p.nome = "Ana";
    p.idade = 25;
    p.apresentar();
  }
}
```

## Construtores
```java
class Ponto {
  int x, y;
  Ponto(int x, int y) { this.x = x; this.y = y; }
}
```

## Encapsulamento
```java
class Conta {
  private double saldo;
  public void depositar(double v) { saldo += v; }
  public double getSaldo() { return saldo; }
}
```

## Herança e Polimorfismo (intro)
```java
class Animal { void som() { System.out.println("som"); } }
class Cachorro extends Animal { void som() { System.out.println("au"); } }

Animal a = new Cachorro();
a.som(); // "au"
```
