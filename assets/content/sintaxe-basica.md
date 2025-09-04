# Sintaxe Básica

## Tipos primitivos
- byte, short, int, long
- float, double
- char, boolean

## Variáveis e Operadores
```java
int a = 10;
int b = 3;
int soma = a + b; // 13
boolean maior = a > b; // true
```

## Entrada e Saída
```java
import java.util.Scanner;

public class Main {
  public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    System.out.print("Seu nome: ");
    String nome = sc.nextLine();
    System.out.println("Olá, " + nome);
    sc.close();
  }
}
```
