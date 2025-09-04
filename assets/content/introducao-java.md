# Introdução ao Java

Java é uma linguagem de programação orientada a objetos criada pela Sun Microsystems (hoje Oracle). É multiplataforma ("write once, run anywhere") e muito usada em back-end, Android, desktop e IoT.

## JDK, JRE e JVM
- JVM: a Máquina Virtual Java, executa bytecode.
- JRE: JVM + bibliotecas padrão para executar aplicações.
- JDK: JRE + ferramentas de desenvolvimento (javac, javadoc, etc.).

## Primeiro Programa
```java
public class Main {
  public static void main(String[] args) {
    System.out.println("Hello, Java!");
  }
}
```
Para compilar: `javac Main.java`. Para executar: `java Main`.

## Boas práticas iniciais
- Nome de classes em PascalCase.
- Use pacotes (package) para organizar código.
- Separe responsabilidades em classes/métodos.
