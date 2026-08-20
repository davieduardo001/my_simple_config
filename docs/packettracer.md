# Cisco Packet Tracer — download manual + instalação

O Packet Tracer **não pode ser 100% automatizado** porque o download da Cisco
exige **login** (conta gratuita no NetAcad). Não tem pacote em repositório
oficial de nenhuma distro — a Cisco distribui um `.deb`.

## 1. Baixar o `.deb` (login obrigatório)

1. Crie/conecte numa conta gratuita em [netacad.com](https://www.netacad.com).
2. Vá em [netacad.com/resources/lab-downloads](https://www.netacad.com/resources/lab-downloads).
3. Baixe o **Cisco Packet Tracer — Ubuntu 64bit** (é um `.deb`, mesmo se for
   usar em Fedora — todos os caminhos partem desse arquivo).
4. Salve o arquivo, ex.: `CiscoPacketTracer_901_Ubuntu_64bit.deb`.

## 2. Instalar com o helper

```bash
./setup.sh packet-tracer /caminho/para/CiscoPacketTracer_xxx_Ubuntu_64bit.deb
```

O helper detecta a distro e faz o caminho certo:

| Distro | Como instala |
|---|---|
| **Ubuntu/Debian** | `sudo apt install ./<deb>` (nativo, resolve deps, abre o EULA) |
| **Fedora** | Clona `thiagoojack/packettracer-rpm-based` e mostra o passo — rode o `./setup` dele e selecione *Install/Upgrade* + escolha o `.deb` |
| **Arch** | Não é alvo desta branch — use a branch `main`/Hyprland (AUR `packettracer`) |

Depois de instalar, o script **garante** o launcher + `.desktop` + ícone em
`~/.local/share/applications` (nos caminhos Ubuntu já vem do pacote; no
Fedora o `.deb` extraído não cria menu por conta própria).

## Observações

- O `.deb` da Cisco é a mesma base em todas as distros; o que muda é só o
  "empacotador" local (apt nativo vs extração).
- Primeira execução pode pedir pra aceitar o EULA — no CLI use **Tab + Enter**.
- Sistema exige: x86-64, ~4GB RAM, ~1.4GB de disco livre.