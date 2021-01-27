Guida semplice di cose da fare dopo aver installato Ubuntu

PS: Alcuni steps sono opzionali in quanto dettati dalle MIE preferenze, che potrebbero non essere uguali alle vostre.

1) Cominciamo lanciando lo script 'programs.sh' tramite il comando 'sh programs.sh' che andrà ad aggiornare apt ed installare in successione i seguenti programmi:

- vlc
- dconf-editor
- grub-customizer
- ubuntu-restricted-extras (codec e MSFont)
- ubuntu-restricted-addons
- suite LibreOffice
- git
- tlp (per battery saving)

e attraverso Snap
- telegram-desktop
- vscode
- phpstorm

 OPZIONALE: SE AVETE SCHEDE NVIDIA
- Andate su Software e Aggiornamenti, e abilitate la prima voce 'Partner di Canonical' in Altro Software, successivamente in Driver Aggiuntivi, selezionate i driver Nvidia proprietari e testati e installateli.


4) OPZIONALE: Fixare il Caps Lock ( fatelo solo se da problemi)
   - mettete la cartella 'capslock-fixer-master' in home ( o dove preferite)
   - aprite 'Applicazioni d'avvio' e aggiungete un programma, alla voce "Comando" inserite 'sh '/home/VOSTRONOME/capslockfixer-master/fixer.sh'
   

   
6) Abilitare le Estensioni Gnome
   - Andate su: https://extensions.gnome.org/
   - Cercate Estensioni e abilitatele. Accettate la conferma.

7) Mettere la Dock nella parte bassa dello schermo.
   - Sempre su Gnome Extensions, attivate l'estensione Dash to Dock
   - Aprite 'Personalizzazioni', e alla voce Estensioni, aprite le impostazioni di Dash To Dock
   - Impostate 'in basso' alla voce Posizione sullo schermo e se volete abilitate 'Nascondi automaticamente intelligente'
   - Alla voce Aspetto, impostate un opacità dinamica.
   
8) OPZIONALE: Aumentare Font caratteri
   - Aprite Personalizzazioni, e alla voce Tipo di Carattere, impostate il valore 1,25

   
9) OPZIONALE: Installare Regolith
  Aggiungere la repo:
sudo add-apt-repository ppa:regolith-linux/release

Installare i packages
sudo apt install regolith-desktop i3xrocks-net-traffic i3xrocks-cpu-usage i3xrocks-time

Per aggiornare correttamente il tema:

sudo snap install regolith-look-ubuntu

Dopo di che, copiare la cartella "etc regolith" al posto di "/etc/regolith"

e la cartella "regolith" al posto di "home/.config/regolith"
