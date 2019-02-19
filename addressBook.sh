#!/bin/bash
#@author: Davide Bianchin	
#Rubrica Telefonica

#controllare il sort con la colonna,ricontrollata generale(visivo)

touch addressBook.txt

#1
#---------------------------------------------------------------------------------------------------------------------
new_contact_name() {
	#leggo nome da input
	echo "Inserire nome:"
	read name
	#mi va ad eliminare gli spazi 
	name=$(echo $name | tr -d ' ')
	#se l'input inserito è uno spazio o un numero richiedo il nome
	if [[ -z "$name" || "$name" =~ [0-9] ]] ; then
		echo "Errore, non hai inserito un nome."
		new_contact_name
	else
		echo "Inserire cognome: " 
		new_contact_surname
		new_contact_cellphone
	fi	
}

new_contact_surname() {
	#leggo cognome da input
	read surname
	surname=$(echo $surname | tr -d ' ')
	#se l'input inserito è uno spazio o un numero richiedo il cognome
	if [[ -z "$surname" || "$surname" =~ [0-9] ]] ; then  
		echo "Errore, non hai inserito un cognome."
		echo "Inserire cognome: "
		new_contact_surname
	fi	
}

new_contact_cellphone(){
	echo "Inserire numero di telefono cellulare: "
	read cellphone
	
	#se l'input non è un numero richiedo il numero di cellulare
	if [[ "$cellphone" =~ ^[0-9]{3,12}$ ]] ; then
		while read nome1 cognome1 cellulare1 telfisso1 data1
		do
			if [[ "$cellphone" == "$cellulare1" ]] ; then
				echo
				echo "Errore, numero inserito già presente in rubrica."
				echo
				return
			fi
		done < addressBook.txt
		new_contact_telephone
	else
		echo "Errore, non hai inserito un numero corretto."
		new_contact_cellphone	
	fi
}		

new_contact_telephone() {
	echo "Inserire numero di telefono fisso: "
	read telephone
	#se l'input non è un numero richiedo il numero di cellulare
	if [[ "$telephone" =~ ^[0-9]{3,12}$ ]] ; then #3,12 mi dice di quante cifre può essere il numero
		while read nome2 cognome2 cellulare2 telfisso2 data2
		do
			if [[ "$telephone" == "$telfisso2" ]] ; then
				echo
				echo "Errore, numero inserito già presente in rubrica"
				echo
				return
			fi
		done < addressBook.txt
		
		new_contact_date
	else
		echo "Errore, non hai inserito un numero corretto."
		new_contact_telephone	
	fi	
}
new_contact_date() {
	echo "Inserire data creazione contatto (nel formato aaaa/mm/gg)."
	read data
	#controllo che la data sia nel formato corretto AAAA/MM/GG
	data_test=$(date -d "$data" +"%Y/%m/%d")
	if ! [[ $? -eq 0 && ${#data} -eq 10 ]] ; then
		echo "La data inserita è nel formato sbagliato." 
		new_contact_date
	else
		touch addressBook.txt
		echo 
		echo "Riepilogo contatto inserito."
		echo  
		echo "Nome: "$name
		echo "Cognome: "$surname
		echo "Cellulare: "$cellphone
		echo "Telefono fisso: "$telephone
		echo "Data creazione: "$data
		echo 
		echo "E' stato creato nella directory Contatti il file per $name $surname."
		echo 
		extra_function
		echo $name $surname $cellphone $telephone $data >> addressBook.txt 		
	fi	
}

#2
#---------------------------------------------------------------------------------------------------------------------
del_contact(){
	echo "+---------------------------------------------------------------+"
	echo "|                     RUBRICA TELEFONICA                        |"
	echo "+---------------------------------------------------------------+"
	cat -n addressBook.txt| column -t
	echo "+---------------------------------------------------------------+"
	echo "Inserire nome da eliminare:"
	read delete_name
	echo "Inserire cognome da eliminare:"
	read delete_surname
	echo "+---------------------------------------------------------------+"
	if [[ -z "$delete_name" || "$delete_name" =~ [0-9] && -z "$delete_surname" || "$delete_surname" =~ [0-9] ]] ; then
		
		echo "Errore non hai inserito un nome o cognome"
		sleep 2
		clear
		del_contact
		
		
	else
		tmp="${delete_name} ${delete_surname} "
		test=$(grep -i -c "$tmp" addressBook.txt)
		display=$(grep -i "$tmp" addressBook.txt)
		case $test in
		
			0) echo "Errore, il contatto inserito non è presente in rubrica."
				echo "Premere un tasto per eliminare un altro contatto,[INVIO] per tornare al menu principale."
				read delete
				if [[ -z $delete && $delete -eq $invio ]] ; then 
					clear
					menu
				fi	
				;;
			1) echo $display
				echo "+---------------------------------------------------------------+"
				echo "Sei sicuro di voler eliminare questo contatto?[y/n]"
				read answer
				case $answer in 
					y) sed --in-place "/$tmp/Id" addressBook.txt 	
						echo "Contatto eliminato."		
						echo "Premere un tasto per eliminare un altro contatto,[INVIO] per tornare al menu principale."
						read delete
						if [[ -z $delete && $delete -eq $invio ]] ; then
							clear
							menu
						fi
						;;
					n) echo "Operazione annullata."
						go_back_to_menu	
						;;
					*) echo "Non hai dato una risposta valida."
						echo "Premere un tasto per eliminare un altro contatto,[INVIO] per tornare al menu principale."
						read delete
						if [[ -z $delete && $delete -eq $invio ]] ; then
							clear
							menu
						fi		
						;;
				esac
				;;
			*) echo
				echo "Sono presenti due o più contatti con lo stesso nome e cognome."
				echo 
				echo "+---------------------------------------------------------------+"
				echo "$display"|column -t
				echo "+---------------------------------------------------------------+"
				echo
				echo "Inserire il numero di telefono cellulare del numero che si vuole eliminare." 
				read num_delete
				if [[ "$num_delete" =~ ^[0-9]{3,12}$ ]] ; then
					sed --in-place "/$num_delete/Id" addressBook.txt
					echo "Contatto eliminato."
					echo "Rubrica aggiornata.."
					sleep 2
					clear
				else
					echo "Non hai inserito un numero corretto."
					sleep 2
				fi
				clear
				echo "+---------------------------------------------------------------+"
				echo "|                     RUBRICA TELEFONICA						  |"
				echo "+---------------------------------------------------------------+"
				cat -n addressBook.txt| column -t
				echo "+---------------------------------------------------------------+"
				echo "Premere un tasto per eliminare un altro contatto,[INVIO] per tornare al menu principale."
				read another_delete
				if [[ -z $another_delete && $another_delete -eq $invio ]] ; then
					clear
					menu
				fi	
			 	;;
		esac	
	fi
}

#3
#---------------------------------------------------------------------------------------------------------------------
print_addressbook() {
	clear
	echo "+---------------------------------------------------------------+"
	echo "|                     RUBRICA TELEFONICA                        |"
	echo "+---------------------------------------------------------------+"
	cat -n addressBook.txt|column -t
	echo "+---------------------------------------------------------------+"
	#mi permette di contare quanti contatti ho nella rubrica
	count=0
	while read
	do
  		((count=$count+1))
	done < addressBook.txt
	echo "La rubrica contiene "$count" contatti."
	echo ""	
	
}

#4
#---------------------------------------------------------------------------------------------------------------------
print_addressbook_sorted() {
	clear
	echo "+---------------------------------------------------------------+"
	echo "Hai selezionato: Stampare rubrica in base ad una ricerca."
	echo "+---------------------------------------------------------------+"
	echo "+---------------------------------------------------------------+"
	echo "|                     RUBRICA TELEFONICA                        |"
	echo "+---------------------------------------------------------------+"
	cat -n addressBook.txt| column -t	
	echo "+---------------------------------------------------------------+"
	echo
	echo "+---------------------------------------------------------------+"
	echo "|                                                               |"
	echo "| Inserire indice della colonna che si desidera ordinare:       |"
	echo "|                                                               |"
	echo "| [1] - Ordinamento alfabetico sul nome.                        |"
	echo "| [2] - Ordinamento alfabetico sul cognome.                     |"
	echo "| [3] - Ordinamento su telefono cellulare.                      |"
	echo "| [4] - Ordinamento su telefono fisso.                          |"
	echo "| [5] - Ordinamento su data inserimento.                        |"
	echo "| [6] - Tornare al menu principale.                             |"
	echo "|                                                               |"
 	echo "+---------------------------------------------------------------+"
 	echo "Inserire opzione: "
	read indice
		case $indice in
			1) clear
				echo
				echo "+----------------------------------------------------+"
				echo "|     RUBRICA TELEFONICA ORDINATA PER NOME:          |"
				echo "+----------------------------------------------------+"
				sort -d -f -k 1 addressBook.txt| column -t #-d dictionary order -f ignore case -k colonna
				echo "+----------------------------------------------------+"
				echo
				echo "Premere un tasto per effettuare un altro ordinamento,[INVIO] per tornare al menu principale."
				read answer1
				if [[ -z $answer1 && $answer1 -eq $invio ]] ; then #funziona, manca caso dello spazio come carattere
					clear
					menu
				fi	
				;;
			2) clear
				echo
				echo "+----------------------------------------------------+"
				echo "|     RUBRICA TELEFONICA ORDINATA PER COGNOME:       |"
				echo "+----------------------------------------------------+"
				sort -d -f -k 2 addressBook.txt| column -t
				echo "+----------------------------------------------------+"
				echo
				echo "Premere un tasto per effettuare un altro ordinamento,[INVIO] per tornare al menu principale."
				read answer2
				if [[ -z $answer2 && $answer2 -eq $invio ]] ; then 
					clear
					menu
				fi	
				;;
			3) clear
				echo
				echo "+----------------------------------------------------+"
				echo "|     RUBRICA TELEFONICA ORDINATA PER N. CELLULARE:  |"
				echo "+----------------------------------------------------+"
				sort -n -k 3 addressBook.txt| column -t
				echo "+----------------------------------------------------+"
				echo
				echo "Premere un tasto per effettuare un altro ordinamento,[INVIO] per tornare al menu principale."
				read answer3
				if [[ -z $answer3 && $answer3 -eq $invio ]] ; then 
					clear
					menu
				fi
				;;
			4) clear
				echo
				echo "+----------------------------------------------------+"
				echo "| RUBRICA TELEFONICA ORDINATA PER N. TELEFONO FISSO: |"
				echo "+----------------------------------------------------+"
				sort -n -k 4 addressBook.txt| column -t
				echo "+---------------------------------------------------+"
				echo
				echo "Premere un tasto per effettuare un altro ordinamento,[INVIO] per tornare al menu principale."
				read answer4
				if [[ -z $answer4 && $answer4 -eq $invio ]] ; then 
					clear
					menu
				fi
				;;
			5) clear
				echo
				echo "+-------------------------------------------------------+"
				echo "|  RUBRICA TELEFONICA ORDINATA PER DATA DI INSERIMENTO: |"
				echo "+-------------------------------------------------------+"
				sort -k 5 addressBook.txt| column -t
				echo "+-------------------------------------------------------+"
				echo
				echo "Premere un tasto per effettuare un altro ordinamento,[INVIO] per tornare al menu principale."
				read answer5
				if [[ -z $answer5 && $answer5 -eq $invio ]] ; then 
					clear
					menu
				fi
				;;
			6) clear
				menu
				;;
			*) echo
				echo "Inserito indice non valido."
				go_back_to_menu	
				;;	
		esac	
}

#5
#---------------------------------------------------------------------------------------------------------------------
search () {
	echo "Inserire nome o cognome o numero di cellulare/fisso o data di creazione del contatto interessato: "
	read scelta
	echo
	echo "+-------------------------------------------------------+"
	if ! [[ -z $scelta ]] ; then
		if grep -i -n $scelta addressBook.txt ; then #-n conta le righe
			echo "+-------------------------------------------------------+"
			echo
			echo "Premere un tasto per effettuare un'altra ricerca,[INVIO] per tornare al menu principale."
			read ricerca
			if [[ -z $ricerca && $ricerca -eq $invio ]] ; then 
				clear
				menu
			fi	
		else	
			echo "Contatto non presente in rubrica."
			echo "+-------------------------------------------------------+"
			echo
			echo "Premere un tasto per effettuare un'altra ricerca,[INVIO] per tornare al menu principale."
			read ricerca2
			if [[ -z $ricerca2 && $ricerca2 -eq $invio ]] ; then 
				clear
				menu
			fi		
		fi
	fi
}

#6
#--------------------------------------------------------------------------------------------------------------------- 
search_date () {
	echo "Ricerca contatto inserito dopo una certa data."
	echo "Inserire data nel formato aaaa/mm/gg:"
	read data_nuova
	echo
	
	data_nuova_test=$(date -d "$data_nuova" +"%Y/%m/%d")
	if ! [[ $? -eq 0 && ${#data_nuova} -eq 10 ]] ; then
		echo "La data inserita è nel formato sbagliato."
		echo
		search_date
	else
		while read nome3 cognome3 cellulare3 telfisso3 data3
		do 
			if [[ "$data_nuova" < "$data3" ]] ; then
				echo "$nome3 $cognome3 $cellulare3 $telfisso3 $data3" >> file.txt
			fi
		done < addressBook.txt|column -t
		
		if [ -f file.txt ] ; then
			cat file.txt| column -t
			rm -f file.txt
		else
			echo "Non sono presenti contatti inseriti dopo la data richiesta."
		fi	
	fi
	echo
	return
}

#7
#---------------------------------------------------------------------------------------------------------------------
open_addressbook_gedit () {
	gedit addressBook.txt
	echo "Hai selezionato: Aprire rubrica con editor di testo."
	go_back_to_menu
	
}

#0
#---------------------------------------------------------------------------------------------------------------------
exit_prog () {
	echo "                                                   "
	echo "Exit program."
	echo "                                                   " #spazio equivale a saltare riga : -e "\n" 
	exit 1
}

#funzione per tornare al menu principale
go_back_to_menu() { #ATTENZIONE quando si inserisce lo spazio va comunque
	echo "Premere INVIO per tornare al menu."
    read invio
    if [[ -z $invio ]] ; then
    	clear
    	menu
	else
		echo " "
		echo "Non hai premuto [INVIO]."
		go_back_to_menu
	fi
}
 

#funzione extra 
extra_function() {
	filename="${name}_${surname}"
	mkdir -p Contatti
	echo "+-------------------------------------------------------
	 			  DETTAGLI CONTATTO                        
-------------------------------------------------------+
Nome : $name
Cognome : $surname
Cellulare : $cellphone
Telefono Fisso : $telephone
Data creazione : $data " > Contatti/$filename.ct 
}
#---------------------------------------------------------------------------------------------------------------------
 
menu() {
	echo " " 
	echo "+-----------------------------------------------------------------+"
	echo "|                  GESTORE RUBRICA TELEFONICA                     |"
	echo "+-----------------------------------------------------------------+"
	echo "|                                                                 |"
	echo "| Selezionare il numero corrispondente all'azione da svolgere:    |"
	echo "|                                                                 |"
	echo "| [1] : Inserire nuovo contatto in rubrica.                       |"
	echo "| [2] : Rimuovere contatto dalla rubrica.                         |"
	echo "| [3] : Stampare rubrica.                                         |"
	echo "| [4] : Stampare la rubrica in ordine di ricerca.                 |"
	echo "| [5] : Ricerca specifica di un nome in rubrica.                  |"
	echo "| [6] : Ricerca di contatti inseriti dopo una certa data.         |"
	echo "| [7] : Aprire rubrica con editor di testo.                       |"
	echo "| [0] : Uscire.                                                   |"
	echo "|                                                                 |"
	echo "+-----------------------------------------------------------------+"
	echo "Cosa si desidera eseguire?"
	read choice
	
	while :;
	do	
		case $choice in 
			1) clear
				echo "+------------------------------------------+"
				echo "Hai selezionato: Inserimento nuovo contatto."
				echo "+------------------------------------------+" 
				new_contact_name
				echo "Premere un tasto per effettuare un altro inserimento,[INVIO] per tornare al menu principale."
				read add	
				if [[ -z $add && $add -eq $invio ]] ; then #funziona,manca caso dello spazio come carattere
					clear
					menu
				fi
				;;
			2) clear
				echo "+-------------------------------------+" 
				echo "Hai selezionato: Eliminazione contatto."
				del_contact
				;;
			3) clear
				print_addressbook
				go_back_to_menu
				;;
			4) clear
				print_addressbook_sorted
				;;
			5) clear
				echo "+----------------------------------+"
				echo "Hai selezionato: Ricerca in rubrica."
				echo "+----------------------------------+"
				search
				;;
			6) clear
				echo ""
				search_date
				echo "Premere un tasto per effettuare un'altra ricerca,[INVIO] per tornare al menu principale."
				read search	
				if [[ -z $search && $search -eq $invio ]] ; then 
					clear
					menu
				fi
				;;
			7) clear
				echo " "
				open_addressbook_gedit
				;;
			0) exit_prog
				;;
			*) clear
			    echo "Inserimento non valido."
			    go_back_to_menu
				;;
		esac
	done
}
#inizio del programma
clear
menu
