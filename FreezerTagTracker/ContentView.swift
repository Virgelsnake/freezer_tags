import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english
    case norwegian
    case spanish
    case french

    static var current: AppLanguage {
        AddContainerSettingsStore().load().language
    }

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en_GB")
        case .norwegian:
            return Locale(identifier: "nb_NO")
        case .spanish:
            return Locale(identifier: "es_ES")
        case .french:
            return Locale(identifier: "fr_FR")
        }
    }

    var speechIdentifier: String {
        switch self {
        case .english:
            return "en-GB"
        case .norwegian:
            return "nb-NO"
        case .spanish:
            return "es-ES"
        case .french:
            return "fr-FR"
        }
    }

    var strings: AppStrings {
        AppStrings(language: self)
    }
}

struct AppStrings {
    let language: AppLanguage

    var locale: Locale { language.locale }

    func languageName(_ language: AppLanguage) -> String {
        switch (self.language, language) {
        case (.english, .english):
            return "English"
        case (.norwegian, .english):
            return "Engelsk"
        case (.spanish, .english):
            return "Ingles"
        case (.french, .english):
            return "Anglais"
        case (.english, .norwegian):
            return "Norwegian"
        case (.english, .spanish):
            return "Spanish"
        case (.english, .french):
            return "French"
        case (.norwegian, .norwegian):
            return "Norsk"
        case (.norwegian, .spanish):
            return "Spansk"
        case (.norwegian, .french):
            return "Fransk"
        case (.spanish, .norwegian):
            return "Noruego"
        case (.spanish, .spanish):
            return "Espanol"
        case (.spanish, .french):
            return "Frances"
        case (.french, .norwegian):
            return "Norvegien"
        case (.french, .spanish):
            return "Espagnol"
        case (.french, .french):
            return "Francais"
        }
    }

    var homeSubtitle: String {
        switch language {
        case .english:
            return "Tap an NFC tag to manage your frozen containers"
        case .norwegian:
            return "Trykk pa en NFC-tag for a administrere fryste beholdere"
        case .spanish:
            return "Toca una etiqueta NFC para gestionar tus recipientes congelados"
        case .french:
            return "Touchez une etiquette NFC pour gerer vos contenants congeles"
        }
    }

    var addContainer: String {
        switch language {
        case .english: return "Add Container"
        case .norwegian: return "Legg til beholder"
        case .spanish: return "Anadir recipiente"
        case .french: return "Ajouter un contenant"
        }
    }

    var scanContainer: String {
        switch language {
        case .english: return "Scan Container"
        case .norwegian: return "Skann beholder"
        case .spanish: return "Escanear recipiente"
        case .french: return "Scanner le contenant"
        }
    }

    var settingsTitle: String {
        switch language {
        case .english: return "Settings"
        case .norwegian: return "Innstillinger"
        case .spanish: return "Ajustes"
        case .french: return "Reglages"
        }
    }

    var loadingContainer: String {
        switch language {
        case .english: return "Loading container..."
        case .norwegian: return "Laster beholder..."
        case .spanish: return "Cargando recipiente..."
        case .french: return "Chargement du contenant..."
        }
    }

    var guidanceSectionTitle: String {
        switch language {
        case .english: return "Guidance"
        case .norwegian: return "Veiledning"
        case .spanish: return "Guia"
        case .french: return "Guidage"
        }
    }

    var spokenGuidance: String {
        switch language {
        case .english: return "Spoken guidance"
        case .norwegian: return "Talt veiledning"
        case .spanish: return "Guia hablada"
        case .french: return "Guidage vocal"
        }
    }

    var spokenConfirmations: String {
        switch language {
        case .english: return "Spoken confirmations"
        case .norwegian: return "Talte bekreftelser"
        case .spanish: return "Confirmaciones habladas"
        case .french: return "Confirmations vocales"
        }
    }

    var haptics: String {
        switch language {
        case .english: return "Haptics"
        case .norwegian: return "Haptikk"
        case .spanish: return "Respuesta tactil"
        case .french: return "Retours haptiques"
        }
    }

    var showMicrophoneShortcut: String {
        switch language {
        case .english: return "Show microphone shortcut"
        case .norwegian: return "Vis mikrofonknapp"
        case .spanish: return "Mostrar acceso rapido al microfono"
        case .french: return "Afficher le raccourci micro"
        }
    }

    var showReadDetailsAgainButton: String {
        switch language {
        case .english: return "Show Read details again button"
        case .norwegian: return "Vis knappen Les detaljene igjen"
        case .spanish: return "Mostrar boton Leer detalles de nuevo"
        case .french: return "Afficher le bouton Relire les details"
        }
    }

    var languageSectionTitle: String {
        switch language {
        case .english: return "Language"
        case .norwegian: return "Sprak"
        case .spanish: return "Idioma"
        case .french: return "Langue"
        }
    }

    var languagePickerLabel: String {
        switch language {
        case .english: return "System language"
        case .norwegian: return "Systemsprak"
        case .spanish: return "Idioma del sistema"
        case .french: return "Langue du systeme"
        }
    }

    var languagePickerDescription: String {
        switch language {
        case .english:
            return "Changes app text, spoken guidance, and VoiceOver announcements."
        case .norwegian:
            return "Endrer apptekst, talt veiledning og VoiceOver-kunngjoringer."
        case .spanish:
            return "Cambia el texto de la app, la guia hablada y los anuncios de VoiceOver."
        case .french:
            return "Change le texte de l'app, le guidage vocal et les annonces VoiceOver."
        }
    }

    var foodExpiryPresetsSectionTitle: String {
        switch language {
        case .english: return "Food expiry presets"
        case .norwegian: return "Forhandsvalg for holdbarhet"
        case .spanish: return "Valores predefinidos de caducidad"
        case .french: return "Reglages des durees de conservation"
        }
    }

    var presetsDescription: String {
        switch language {
        case .english:
            return "These dates are suggested for best quality and can be changed."
        case .norwegian:
            return "Disse datoene er forslag for best kvalitet og kan endres."
        case .spanish:
            return "Estas fechas son sugerencias de mejor calidad y se pueden cambiar."
        case .french:
            return "Ces dates sont des suggestions pour une qualite optimale et peuvent etre modifiees."
        }
    }

    var editPresetMonthValues: String {
        switch language {
        case .english: return "Edit preset month values"
        case .norwegian: return "Rediger forhondsvalgte maneder"
        case .spanish: return "Editar meses predefinidos"
        case .french: return "Modifier les mois predefinis"
        }
    }

    var suggestedDatesResettable: String {
        switch language {
        case .english: return "Suggested best-quality dates can be reset at any time."
        case .norwegian: return "Forslag til best-kvalitetsdatoer kan nullstilles nar som helst."
        case .spanish: return "Las fechas sugeridas de mejor calidad se pueden restablecer en cualquier momento."
        case .french: return "Les dates suggerees de qualite optimale peuvent etre reinitialisees a tout moment."
        }
    }

    var resetToDefaults: String {
        switch language {
        case .english: return "Reset to defaults"
        case .norwegian: return "Tilbakestill til standard"
        case .spanish: return "Restablecer valores"
        case .french: return "Reinitialiser"
        }
    }

    var noAutomaticDate: String {
        switch language {
        case .english: return "No automatic date"
        case .norwegian: return "Ingen automatisk dato"
        case .spanish: return "Sin fecha automatica"
        case .french: return "Aucune date automatique"
        }
    }

    func monthLabel(_ months: Int) -> String {
        switch language {
        case .english:
            return months == 1 ? "1 month" : "\(months) months"
        case .norwegian:
            return months == 1 ? "1 maned" : "\(months) maneder"
        case .spanish:
            return months == 1 ? "1 mes" : "\(months) meses"
        case .french:
            return months == 1 ? "1 mois" : "\(months) mois"
        }
    }

    var step1Of2: String {
        switch language {
        case .english: return "Step 1 of 2"
        case .norwegian: return "Trinn 1 av 2"
        case .spanish: return "Paso 1 de 2"
        case .french: return "Etape 1 sur 2"
        }
    }

    var step2Of2: String {
        switch language {
        case .english: return "Step 2 of 2"
        case .norwegian: return "Trinn 2 av 2"
        case .spanish: return "Paso 2 de 2"
        case .french: return "Etape 2 sur 2"
        }
    }

    var addContainerTitle: String {
        switch language {
        case .english: return "Add a container"
        case .norwegian: return "Legg til en beholder"
        case .spanish: return "Anadir un recipiente"
        case .french: return "Ajouter un contenant"
        }
    }

    var addContainerSubtitle: String {
        switch language {
        case .english:
            return "Tell us what you are freezing, then we will help you write it to the tag."
        case .norwegian:
            return "Fortell hva du fryser, sa hjelper vi deg med a skrive det til taggen."
        case .spanish:
            return "Dinos que vas a congelar y luego te ayudaremos a escribirlo en la etiqueta."
        case .french:
            return "Dites-nous ce que vous congelez, puis nous vous aiderons a l'ecrire sur l'etiquette."
        }
    }

    var addContainerAccessibilityHeader: String {
        "\(step1Of2). \(addContainerTitle). \(addContainerSubtitle)"
    }

    var foodName: String {
        switch language {
        case .english: return "Food name"
        case .norwegian: return "Matnavn"
        case .spanish: return "Nombre del alimento"
        case .french: return "Nom de l'aliment"
        }
    }

    var foodNameExample: String {
        switch language {
        case .english: return "Example: Beef stew"
        case .norwegian: return "Eksempel: Biffgryte"
        case .spanish: return "Ejemplo: Estofado de ternera"
        case .french: return "Exemple : Boeuf mijote"
        }
    }

    var required: String {
        switch language {
        case .english: return "Required"
        case .norwegian: return "Obligatorisk"
        case .spanish: return "Obligatorio"
        case .french: return "Obligatoire"
        }
    }

    var empty: String {
        switch language {
        case .english: return "Empty"
        case .norwegian: return "Tom"
        case .spanish: return "Vacio"
        case .french: return "Vide"
        }
    }

    var foodNameRequiredMessage: String {
        switch language {
        case .english: return "Food name is required."
        case .norwegian: return "Matnavn er obligatorisk."
        case .spanish: return "El nombre del alimento es obligatorio."
        case .french: return "Le nom de l'aliment est obligatoire."
        }
    }

    var foodNameRequiredToContinue: String {
        switch language {
        case .english: return "Enter a food name to continue"
        case .norwegian: return "Skriv inn et matnavn for a fortsette"
        case .spanish: return "Introduce un nombre de alimento para continuar"
        case .french: return "Saisissez un nom d'aliment pour continuer"
        }
    }

    var foodNameFieldHint: String {
        switch language {
        case .english: return "Required text field. Double tap to type or use dictation."
        case .norwegian: return "Obligatorisk tekstfelt. Dobbelttrykk for a skrive eller bruke diktering."
        case .spanish: return "Campo de texto obligatorio. Toca dos veces para escribir o usar dictado."
        case .french: return "Champ de texte obligatoire. Touchez deux fois pour saisir ou dicter."
        }
    }

    var chooseFoodType: String {
        switch language {
        case .english: return "Choose a food type"
        case .norwegian: return "Velg en mattype"
        case .spanish: return "Elige un tipo de alimento"
        case .french: return "Choisissez un type d'aliment"
        }
    }

    var foodType: String {
        switch language {
        case .english: return "Food type"
        case .norwegian: return "Mattype"
        case .spanish: return "Tipo de alimento"
        case .french: return "Type d'aliment"
        }
    }

    var foodTypeSuggestionDescription: String {
        switch language {
        case .english: return "This can add a suggested best-quality date."
        case .norwegian: return "Dette kan legge til en foreslatt best-kvalitetsdato."
        case .spanish: return "Esto puede anadir una fecha sugerida de mejor calidad."
        case .french: return "Cela peut ajouter une date suggeree de qualite optimale."
        }
    }

    func presetAccessibilityHint(isSelected: Bool) -> String {
        switch language {
        case .english:
            return "Adds a suggested best-quality date based on USDA guidance."
        case .norwegian:
            return "Legger til en foreslatt best-kvalitetsdato basert pa USDA-veiledning."
        case .spanish:
            return "Anade una fecha sugerida de mejor calidad segun la guia del USDA."
        case .french:
            return "Ajoute une date suggeree de qualite optimale selon les recommandations USDA."
        }
    }

    var selected: String {
        switch language {
        case .english: return "Selected"
        case .norwegian: return "Valgt"
        case .spanish: return "Seleccionado"
        case .french: return "Selectionne"
        }
    }

    var notSelected: String {
        switch language {
        case .english: return "Not selected"
        case .norwegian: return "Ikke valgt"
        case .spanish: return "No seleccionado"
        case .french: return "Non selectionne"
        }
    }

    var dateFrozen: String {
        switch language {
        case .english: return "Date frozen"
        case .norwegian: return "Dato fryst"
        case .spanish: return "Fecha de congelacion"
        case .french: return "Date de congelation"
        }
    }

    var bestQualityBy: String {
        switch language {
        case .english: return "Best quality by"
        case .norwegian: return "Best kvalitet innen"
        case .spanish: return "Mejor calidad antes de"
        case .french: return "Qualite optimale avant le"
        }
    }

    var notes: String {
        switch language {
        case .english: return "Notes"
        case .norwegian: return "Notater"
        case .spanish: return "Notas"
        case .french: return "Notes"
        }
    }

    var optionalNotes: String {
        switch language {
        case .english: return "Optional notes"
        case .norwegian: return "Valgfrie notater"
        case .spanish: return "Notas opcionales"
        case .french: return "Notes facultatives"
        }
    }

    var notSet: String {
        switch language {
        case .english: return "Not set"
        case .norwegian: return "Ikke satt"
        case .spanish: return "Sin definir"
        case .french: return "Non defini"
        }
    }

    func optionalNotesPlaceholder(example: Bool = false) -> String {
        switch language {
        case .english:
            return example ? "Optional notes (e.g., ingredients, portions)" : "Optional notes"
        case .norwegian:
            return example ? "Valgfrie notater (f.eks. ingredienser, porsjoner)" : "Valgfrie notater"
        case .spanish:
            return example ? "Notas opcionales (p. ej., ingredientes, raciones)" : "Notas opcionales"
        case .french:
            return example ? "Notes facultatives (ex. ingredients, portions)" : "Notes facultatives"
        }
    }

    func optionalUpToCharacters(_ count: Int) -> String {
        switch language {
        case .english:
            return "Optional. Up to \(count) characters."
        case .norwegian:
            return "Valgfritt. Opptil \(count) tegn."
        case .spanish:
            return "Opcional. Hasta \(count) caracteres."
        case .french:
            return "Facultatif. Jusqu'a \(count) caracteres."
        }
    }

    func charactersCount(_ current: Int, limit: Int) -> String {
        switch language {
        case .english: return "\(current) of \(limit) characters"
        case .norwegian: return "\(current) av \(limit) tegn"
        case .spanish: return "\(current) de \(limit) caracteres"
        case .french: return "\(current) sur \(limit) caracteres"
        }
    }

    var reviewAndWriteToTag: String {
        switch language {
        case .english: return "Review and write to tag"
        case .norwegian: return "Se gjennom og skriv til tagg"
        case .spanish: return "Revisar y escribir en la etiqueta"
        case .french: return "Verifier et ecrire sur l'etiquette"
        }
    }

    func reviewButtonHint(canProceed: Bool) -> String {
        switch language {
        case .english:
            return canProceed
                ? "Moves to the final review screen before writing to the tag."
                : "Disabled. Food name is required."
        case .norwegian:
            return canProceed
                ? "Gaar til siste kontrollskjerm for du skriver til taggen."
                : "Deaktivert. Matnavn er obligatorisk."
        case .spanish:
            return canProceed
                ? "Pasa a la pantalla final de revision antes de escribir en la etiqueta."
                : "Desactivado. El nombre del alimento es obligatorio."
        case .french:
            return canProceed
                ? "Passe a l'ecran final de verification avant l'ecriture sur l'etiquette."
                : "Desactive. Le nom de l'aliment est obligatoire."
        }
    }

    var cancel: String {
        switch language {
        case .english: return "Cancel"
        case .norwegian: return "Avbryt"
        case .spanish: return "Cancelar"
        case .french: return "Annuler"
        }
    }

    var done: String {
        switch language {
        case .english: return "Done"
        case .norwegian: return "Ferdig"
        case .spanish: return "Listo"
        case .french: return "Termine"
        }
    }

    var save: String {
        switch language {
        case .english: return "Save"
        case .norwegian: return "Lagre"
        case .spanish: return "Guardar"
        case .french: return "Enregistrer"
        }
    }

    var saving: String {
        switch language {
        case .english: return "Saving..."
        case .norwegian: return "Lagrer..."
        case .spanish: return "Guardando..."
        case .french: return "Enregistrement..."
        }
    }

    var reviewAndWrite: String {
        switch language {
        case .english: return "Review and write"
        case .norwegian: return "Se gjennom og skriv"
        case .spanish: return "Revisar y escribir"
        case .french: return "Verifier et ecrire"
        }
    }

    var reviewSubtitle: String {
        switch language {
        case .english: return "Check these details, then hold your iPhone near the tag."
        case .norwegian: return "Kontroller disse detaljene, og hold deretter iPhone naer taggen."
        case .spanish: return "Comprueba estos detalles y luego acerca tu iPhone a la etiqueta."
        case .french: return "Verifiez ces details, puis approchez votre iPhone de l'etiquette."
        }
    }

    var reviewAccessibilityHeader: String {
        "\(step2Of2). \(reviewAndWrite). \(reviewSubtitle)"
    }

    var whatWillBeSaved: String {
        switch language {
        case .english: return "What will be saved"
        case .norwegian: return "Dette blir lagret"
        case .spanish: return "Lo que se guardara"
        case .french: return "Ce qui sera enregistre"
        }
    }

    var readDetailsAgain: String {
        switch language {
        case .english: return "Read details again"
        case .norwegian: return "Les detaljene igjen"
        case .spanish: return "Leer detalles de nuevo"
        case .french: return "Relire les details"
        }
    }

    var readDetailsAgainHint: String {
        switch language {
        case .english: return "Speaks the details that will be written to the tag."
        case .norwegian: return "Leser opp detaljene som skal skrives til taggen."
        case .spanish: return "Lee los detalles que se escribiran en la etiqueta."
        case .french: return "Lit les details qui seront ecrits sur l'etiquette."
        }
    }

    var writeToTag: String {
        switch language {
        case .english: return "Write to tag"
        case .norwegian: return "Skriv til tagg"
        case .spanish: return "Escribir en la etiqueta"
        case .french: return "Ecrire sur l'etiquette"
        }
    }

    var writingToTag: String {
        switch language {
        case .english: return "Writing to tag..."
        case .norwegian: return "Skriver til tagg..."
        case .spanish: return "Escribiendo en la etiqueta..."
        case .french: return "Ecriture sur l'etiquette..."
        }
    }

    var writeToTagHint: String {
        switch language {
        case .english: return "Starts the tag writing step."
        case .norwegian: return "Starter skrivingen til taggen."
        case .spanish: return "Inicia el paso de escritura en la etiqueta."
        case .french: return "Lance l'etape d'ecriture sur l'etiquette."
        }
    }

    var goBackAndChange: String {
        switch language {
        case .english: return "Go back and change"
        case .norwegian: return "Ga tilbake og endre"
        case .spanish: return "Volver y cambiar"
        case .french: return "Revenir et modifier"
        }
    }

    var goBack: String {
        switch language {
        case .english: return "Go back"
        case .norwegian: return "Ga tilbake"
        case .spanish: return "Volver"
        case .french: return "Retour"
        }
    }

    var goBackHint: String {
        switch language {
        case .english: return "Returns to the previous screen to edit the details."
        case .norwegian: return "Gaar tilbake til forrige skjerm for a endre detaljene."
        case .spanish: return "Vuelve a la pantalla anterior para editar los detalles."
        case .french: return "Revient a l'ecran precedent pour modifier les details."
        }
    }

    var holdPhoneNearTag: String {
        switch language {
        case .english: return "Hold your phone near the tag"
        case .norwegian: return "Hold telefonen naer taggen"
        case .spanish: return "Acerca el telefono a la etiqueta"
        case .french: return "Approchez votre telephone de l'etiquette"
        }
    }

    var holdPhoneNearTagSubtitle: String {
        switch language {
        case .english:
            return "Keep the top of your iPhone close to the container tag until you feel confirmation."
        case .norwegian:
            return "Hold toppen av iPhone naer beholdertaggen til du far bekreftelse."
        case .spanish:
            return "Manten la parte superior de tu iPhone cerca de la etiqueta del recipiente hasta notar la confirmacion."
        case .french:
            return "Gardez le haut de votre iPhone pres de l'etiquette du contenant jusqu'a ressentir la confirmation."
        }
    }

    var writingInProgress: String {
        switch language {
        case .english: return "Writing in progress"
        case .norwegian: return "Skriving pabegynt"
        case .spanish: return "Escritura en curso"
        case .french: return "Ecriture en cours"
        }
    }

    var reducedMotionWritingHint: String {
        switch language {
        case .english: return "Animation is reduced. Keep holding your phone near the tag."
        case .norwegian: return "Animasjonen er redusert. Hold fortsatt telefonen naer taggen."
        case .spanish: return "La animacion esta reducida. Sigue manteniendo el telefono cerca de la etiqueta."
        case .french: return "L'animation est reduite. Continuez a garder votre telephone pres de l'etiquette."
        }
    }

    var saved: String {
        switch language {
        case .english: return "Saved"
        case .norwegian: return "Lagret"
        case .spanish: return "Guardado"
        case .french: return "Enregistre"
        }
    }

    var needsAttention: String {
        switch language {
        case .english: return "Needs attention"
        case .norwegian: return "Krever oppmerksomhet"
        case .spanish: return "Requiere atencion"
        case .french: return "Attention requise"
        }
    }

    var savedToContainerTitle: String {
        switch language {
        case .english: return "Saved to your container"
        case .norwegian: return "Lagret pa beholderen"
        case .spanish: return "Guardado en tu recipiente"
        case .french: return "Enregistre sur votre contenant"
        }
    }

    func savedToContainerMessage(foodName: String) -> String {
        switch language {
        case .english: return "\(foodName) has been saved and the tag was updated."
        case .norwegian: return "\(foodName) er lagret og taggen ble oppdatert."
        case .spanish: return "\(foodName) se ha guardado y la etiqueta se ha actualizado."
        case .french: return "\(foodName) a ete enregistre et l'etiquette a ete mise a jour."
        }
    }

    var saveFailedTitle: String {
        switch language {
        case .english: return "That did not save to the tag"
        case .norwegian: return "Det ble ikke lagret pa taggen"
        case .spanish: return "No se guardo en la etiqueta"
        case .french: return "L'enregistrement sur l'etiquette a echoue"
        }
    }

    var saveFailedMessage: String {
        switch language {
        case .english: return "Try holding your iPhone a little closer and keep it still."
        case .norwegian: return "Prov a holde iPhone litt naermere og helt i ro."
        case .spanish: return "Prueba a mantener tu iPhone un poco mas cerca y quieto."
        case .french: return "Essayez de tenir votre iPhone un peu plus pres et sans bouger."
        }
    }

    var replaySavedDetailsHint: String {
        switch language {
        case .english: return "Replays the saved container details."
        case .norwegian: return "Leser opp de lagrede beholderdetaljene pa nytt."
        case .spanish: return "Reproduce de nuevo los detalles guardados del recipiente."
        case .french: return "Relit les details enregistres du contenant."
        }
    }

    var reviewSavedDetailsHint: String {
        switch language {
        case .english: return "Review the saved details before writing to the tag."
        case .norwegian: return "Kontroller de lagrede detaljene for du skriver til taggen."
        case .spanish: return "Revisa los detalles guardados antes de escribir en la etiqueta."
        case .french: return "Verifiez les details enregistres avant l'ecriture sur l'etiquette."
        }
    }

    var tryAgain: String {
        switch language {
        case .english: return "Try again"
        case .norwegian: return "Prov igjen"
        case .spanish: return "Intentar de nuevo"
        case .french: return "Reessayer"
        }
    }

    var goBackToReviewHint: String {
        switch language {
        case .english: return "Returns to the review step without losing the details."
        case .norwegian: return "Gar tilbake til kontrollsteget uten a miste detaljene."
        case .spanish: return "Vuelve al paso de revision sin perder los detalles."
        case .french: return "Revient a l'etape de verification sans perdre les details."
        }
    }

    var readyToScan: String {
        switch language {
        case .english: return "Ready to scan. Hold your iPhone near the container tag."
        case .norwegian: return "Klar til skanning. Hold iPhone naer beholdertaggen."
        case .spanish: return "Listo para escanear. Acerca tu iPhone a la etiqueta del recipiente."
        case .french: return "Pret a scanner. Approchez votre iPhone de l'etiquette du contenant."
        }
    }

    var scanFailed: String {
        switch language {
        case .english: return "Scan Failed"
        case .norwegian: return "Skanning mislyktes"
        case .spanish: return "Error al escanear"
        case .french: return "Echec du scan"
        }
    }

    var containerDetails: String {
        switch language {
        case .english: return "Container Details"
        case .norwegian: return "Beholderdetaljer"
        case .spanish: return "Detalles del recipiente"
        case .french: return "Details du contenant"
        }
    }

    var bestBefore: String {
        switch language {
        case .english: return "Best Before"
        case .norwegian: return "Best for"
        case .spanish: return "Consumir preferentemente antes de"
        case .french: return "A consommer de preference avant"
        }
    }

    var tagID: String {
        switch language {
        case .english: return "Tag ID"
        case .norwegian: return "Tagg-ID"
        case .spanish: return "ID de etiqueta"
        case .french: return "ID de l'etiquette"
        }
    }

    var technicalDetails: String {
        switch language {
        case .english: return "Technical Details"
        case .norwegian: return "Tekniske detaljer"
        case .spanish: return "Detalles tecnicos"
        case .french: return "Details techniques"
        }
    }

    var edit: String {
        switch language {
        case .english: return "Edit"
        case .norwegian: return "Rediger"
        case .spanish: return "Editar"
        case .french: return "Modifier"
        }
    }

    var clearAndReuse: String {
        switch language {
        case .english: return "Clear & Reuse"
        case .norwegian: return "Tom og gjenbruk"
        case .spanish: return "Vaciar y reutilizar"
        case .french: return "Vider et reutiliser"
        }
    }

    var clearContainerTitle: String {
        switch language {
        case .english: return "Clear Container"
        case .norwegian: return "Tom beholder"
        case .spanish: return "Vaciar recipiente"
        case .french: return "Vider le contenant"
        }
    }

    var clearContainerMessage: String {
        switch language {
        case .english:
            return "This will mark the container as empty and ready for reuse. The tag can be rewritten with new information."
        case .norwegian:
            return "Dette markerer beholderen som tom og klar for gjenbruk. Taggen kan skrives pa nytt med ny informasjon."
        case .spanish:
            return "Esto marcara el recipiente como vacio y listo para reutilizar. La etiqueta se podra reescribir con nueva informacion."
        case .french:
            return "Cela marquera le contenant comme vide et pret a etre reutilise. L'etiquette pourra etre reecrite avec de nouvelles informations."
        }
    }

    func daysLeft(_ days: Int) -> String {
        switch language {
        case .english: return "\(days)d left"
        case .norwegian: return "\(days)d igjen"
        case .spanish: return "Quedan \(days)d"
        case .french: return "\(days) j restants"
        }
    }

    func daysAgoShort(_ days: Int) -> String {
        switch language {
        case .english: return "\(days)d ago"
        case .norwegian: return "for \(days)d siden"
        case .spanish: return "hace \(days)d"
        case .french: return "il y a \(days) j"
        }
    }

    var editContainerTitle: String {
        switch language {
        case .english: return "Edit Container"
        case .norwegian: return "Rediger beholder"
        case .spanish: return "Editar recipiente"
        case .french: return "Modifier le contenant"
        }
    }

    var containerInformation: String {
        switch language {
        case .english: return "Container Information"
        case .norwegian: return "Beholderinformasjon"
        case .spanish: return "Informacion del recipiente"
        case .french: return "Informations sur le contenant"
        }
    }

    var setBestBeforeDate: String {
        switch language {
        case .english: return "Set Best Before Date"
        case .norwegian: return "Sett best for-dato"
        case .spanish: return "Establecer fecha de consumo preferente"
        case .french: return "Definir la date de consommation"
        }
    }

    var bestBeforeOptional: String {
        switch language {
        case .english: return "Best Before Date (Optional)"
        case .norwegian: return "Best for-dato (valgfritt)"
        case .spanish: return "Fecha de consumo preferente (opcional)"
        case .french: return "Date de consommation (facultative)"
        }
    }

    var bestBeforeInfo: String {
        switch language {
        case .english: return "You'll be notified when the date approaches or passes"
        case .norwegian: return "Du blir varslet nar datoen naermer seg eller passeres"
        case .spanish: return "Recibiras un aviso cuando la fecha se acerque o se supere"
        case .french: return "Vous serez averti lorsque la date approchera ou sera depassee"
        }
    }

    func charactersRemaining(_ count: Int) -> String {
        switch language {
        case .english: return "\(count) characters remaining"
        case .norwegian: return "\(count) tegn igjen"
        case .spanish: return "Quedan \(count) caracteres"
        case .french: return "\(count) caracteres restants"
        }
    }

    var validationErrorTitle: String {
        switch language {
        case .english: return "Validation Error"
        case .norwegian: return "Valideringsfeil"
        case .spanish: return "Error de validacion"
        case .french: return "Erreur de validation"
        }
    }

    var pleaseEnterFoodName: String {
        switch language {
        case .english: return "Please enter a food name"
        case .norwegian: return "Skriv inn et matnavn"
        case .spanish: return "Introduce un nombre de alimento"
        case .french: return "Veuillez saisir un nom d'aliment"
        }
    }

    var notesMustBeShorter: String {
        switch language {
        case .english: return "Notes must be 200 characters or less"
        case .norwegian: return "Notater ma vaere 200 tegn eller kortere"
        case .spanish: return "Las notas deben tener 200 caracteres o menos"
        case .french: return "Les notes doivent contenir 200 caracteres ou moins"
        }
    }

    var stopListening: String {
        switch language {
        case .english: return "Stop listening"
        case .norwegian: return "Stopp lytting"
        case .spanish: return "Dejar de escuchar"
        case .french: return "Arreter l'ecoute"
        }
    }

    var preparingMicrophone: String {
        switch language {
        case .english: return "Preparing microphone..."
        case .norwegian: return "Klargjorer mikrofon..."
        case .spanish: return "Preparando microfono..."
        case .french: return "Preparation du micro..."
        }
    }

    var microphoneUnavailable: String {
        switch language {
        case .english: return "Microphone input is unavailable right now. Please try again on your iPhone."
        case .norwegian: return "Mikrofoninngangen er ikke tilgjengelig akkurat na. Prov igjen pa iPhone."
        case .spanish: return "La entrada del microfono no esta disponible ahora mismo. Intentalo de nuevo en tu iPhone."
        case .french: return "L'entree micro est indisponible pour le moment. Reessayez sur votre iPhone."
        }
    }

    var speechRecognitionUnavailable: String {
        switch language {
        case .english: return "Speech recognition is unavailable on this device."
        case .norwegian: return "Talegjenkjenning er ikke tilgjengelig pa denne enheten."
        case .spanish: return "El reconocimiento de voz no esta disponible en este dispositivo."
        case .french: return "La reconnaissance vocale n'est pas disponible sur cet appareil."
        }
    }

    var couldNotStartListening: String {
        switch language {
        case .english: return "We couldn't start listening right now. Please try again."
        case .norwegian: return "Vi kunne ikke starte lytting akkurat na. Prov igjen."
        case .spanish: return "No pudimos empezar a escuchar ahora mismo. Intentalo de nuevo."
        case .french: return "Impossible de demarrer l'ecoute pour le moment. Reessayez."
        }
    }

    var speakFoodName: String {
        switch language {
        case .english: return "Speak food name"
        case .norwegian: return "Si matnavn"
        case .spanish: return "Decir nombre del alimento"
        case .french: return "Dire le nom de l'aliment"
        }
    }

    var listeningForFoodName: String {
        switch language {
        case .english: return "Listening for food name."
        case .norwegian: return "Lytter etter matnavn."
        case .spanish: return "Escuchando el nombre del alimento."
        case .french: return "Ecoute du nom de l'aliment."
        }
    }

    var allowSpeechRecognitionForFoodName: String {
        switch language {
        case .english: return "Allow speech recognition in Settings to use Speak food name."
        case .norwegian: return "Tillat talegjenkjenning i Innstillinger for a bruke Si matnavn."
        case .spanish: return "Permite el reconocimiento de voz en Ajustes para usar Decir nombre del alimento."
        case .french: return "Autorisez la reconnaissance vocale dans Reglages pour utiliser Dire le nom de l'aliment."
        }
    }

    var allowMicrophoneForFoodName: String {
        switch language {
        case .english: return "Allow microphone access in Settings to use Speak food name."
        case .norwegian: return "Tillat mikrofontilgang i Innstillinger for a bruke Si matnavn."
        case .spanish: return "Permite el acceso al microfono en Ajustes para usar Decir nombre del alimento."
        case .french: return "Autorisez l'acces au micro dans Reglages pour utiliser Dire le nom de l'aliment."
        }
    }

    var speakToAddNote: String {
        switch language {
        case .english: return "Speak to add note"
        case .norwegian: return "Si for a legge til notat"
        case .spanish: return "Hablar para anadir nota"
        case .french: return "Parler pour ajouter une note"
        }
    }

    var listeningForNote: String {
        switch language {
        case .english: return "Listening for note."
        case .norwegian: return "Lytter etter notat."
        case .spanish: return "Escuchando la nota."
        case .french: return "Ecoute de la note."
        }
    }

    var allowSpeechRecognitionForNote: String {
        switch language {
        case .english: return "Allow speech recognition in Settings to use Speak to add note."
        case .norwegian: return "Tillat talegjenkjenning i Innstillinger for a bruke Si for a legge til notat."
        case .spanish: return "Permite el reconocimiento de voz en Ajustes para usar Hablar para anadir nota."
        case .french: return "Autorisez la reconnaissance vocale dans Reglages pour utiliser Parler pour ajouter une note."
        }
    }

    var allowMicrophoneForNote: String {
        switch language {
        case .english: return "Allow microphone access in Settings to use Speak to add note."
        case .norwegian: return "Tillat mikrofontilgang i Innstillinger for a bruke Si for a legge til notat."
        case .spanish: return "Permite el acceso al microfono en Ajustes para usar Hablar para anadir nota."
        case .french: return "Autorisez l'acces au micro dans Reglages pour utiliser Parler pour ajouter une note."
        }
    }

    var stopListeningHint: String {
        switch language {
        case .english: return "Double tap to stop listening."
        case .norwegian: return "Dobbelttrykk for a stoppe lytting."
        case .spanish: return "Toca dos veces para dejar de escuchar."
        case .french: return "Touchez deux fois pour arreter l'ecoute."
        }
    }

    var dictateFoodNameHint: String {
        switch language {
        case .english: return "Double tap to dictate the name of the food."
        case .norwegian: return "Dobbelttrykk for a diktere navnet pa maten."
        case .spanish: return "Toca dos veces para dictar el nombre del alimento."
        case .french: return "Touchez deux fois pour dicter le nom de l'aliment."
        }
    }

    var dictateNoteHint: String {
        switch language {
        case .english: return "Double tap to dictate a note."
        case .norwegian: return "Dobbelttrykk for a diktere et notat."
        case .spanish: return "Toca dos veces para dictar una nota."
        case .french: return "Touchez deux fois pour dicter une note."
        }
    }

    var changeDateHint: String {
        switch language {
        case .english: return "Double tap to change the date."
        case .norwegian: return "Dobbelttrykk for a endre datoen."
        case .spanish: return "Toca dos veces para cambiar la fecha."
        case .french: return "Touchez deux fois pour modifier la date."
        }
    }

    var closeAddContainerHint: String {
        switch language {
        case .english: return "Closes the add-container flow without saving."
        case .norwegian: return "Lukker legg-til-beholder-flyten uten a lagre."
        case .spanish: return "Cierra el flujo de anadir recipiente sin guardar."
        case .french: return "Ferme le parcours d'ajout de contenant sans enregistrer."
        }
    }

    var cancelFlowHint: String {
        switch language {
        case .english: return "Returns to the home screen without saving this container."
        case .norwegian: return "Gar tilbake til startskjermen uten a lagre denne beholderen."
        case .spanish: return "Vuelve a la pantalla principal sin guardar este recipiente."
        case .french: return "Revient a l'ecran d'accueil sans enregistrer ce contenant."
        }
    }

    var removeDate: String {
        switch language {
        case .english: return "Remove date"
        case .norwegian: return "Fjern dato"
        case .spanish: return "Quitar fecha"
        case .french: return "Supprimer la date"
        }
    }

    func foodCategory(_ category: FoodCategory) -> String {
        switch (language, category) {
        case (.english, .beef): return "Beef"
        case (.english, .fish): return "Fish"
        case (.english, .pastries): return "Pastries"
        case (.english, .poultry): return "Poultry"
        case (.english, .preparedMeal): return "Prepared meal"
        case (.english, .vegetables): return "Vegetables"
        case (.english, .other): return "Other"
        case (.norwegian, .beef): return "Storfe"
        case (.norwegian, .fish): return "Fisk"
        case (.norwegian, .pastries): return "Bakst"
        case (.norwegian, .poultry): return "Fjorkre"
        case (.norwegian, .preparedMeal): return "Ferdigmat"
        case (.norwegian, .vegetables): return "Gronsaker"
        case (.norwegian, .other): return "Annet"
        case (.spanish, .beef): return "Ternera"
        case (.spanish, .fish): return "Pescado"
        case (.spanish, .pastries): return "Bolleria"
        case (.spanish, .poultry): return "Ave"
        case (.spanish, .preparedMeal): return "Plato preparado"
        case (.spanish, .vegetables): return "Verduras"
        case (.spanish, .other): return "Otro"
        case (.french, .beef): return "Boeuf"
        case (.french, .fish): return "Poisson"
        case (.french, .pastries): return "Patisseries"
        case (.french, .poultry): return "Volaille"
        case (.french, .preparedMeal): return "Plat prepare"
        case (.french, .vegetables): return "Legumes"
        case (.french, .other): return "Autre"
        }
    }

    func dateString(_ date: Date, dateStyle: DateFormatter.Style = .medium, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = dateStyle
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func longDateString(_ date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        return formatter.string(from: date)
    }

    func today(relativeTo referenceDate: Date, comparedTo date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            switch language {
            case .english: return "Today"
            case .norwegian: return "I dag"
            case .spanish: return "Hoy"
            case .french: return "Aujourd'hui"
            }
        }

        return longDateString(date, calendar: calendar)
    }

    func frozenOn(_ date: Date, calendar: Calendar = .current) -> String {
        switch language {
        case .english:
            return "Frozen on \(dateString(date, calendar: calendar))"
        case .norwegian:
            return "Fryst \(dateString(date, calendar: calendar))"
        case .spanish:
            return "Congelado el \(dateString(date, calendar: calendar))"
        case .french:
            return "Congele le \(dateString(date, calendar: calendar))"
        }
    }

    func daysFrozenDescription(_ days: Int) -> String {
        switch language {
        case .english:
            if days == 0 { return "Frozen today" }
            if days == 1 { return "1 day ago" }
            return "\(days) days ago"
        case .norwegian:
            if days == 0 { return "Fryst i dag" }
            if days == 1 { return "for 1 dag siden" }
            return "for \(days) dager siden"
        case .spanish:
            if days == 0 { return "Congelado hoy" }
            if days == 1 { return "Hace 1 dia" }
            return "Hace \(days) dias"
        case .french:
            if days == 0 { return "Congele aujourd'hui" }
            if days == 1 { return "Il y a 1 jour" }
            return "Il y a \(days) jours"
        }
    }

    func foodTypeSummary(_ category: FoodCategory) -> String {
        switch language {
        case .english: return "Food type \(foodCategory(category))"
        case .norwegian: return "Mattype \(foodCategory(category))"
        case .spanish: return "Tipo de alimento \(foodCategory(category))"
        case .french: return "Type d'aliment \(foodCategory(category))"
        }
    }

    func frozenSummary(_ date: Date, referenceDate: Date, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            switch language {
            case .english: return "Frozen today"
            case .norwegian: return "Fryst i dag"
            case .spanish: return "Congelado hoy"
            case .french: return "Congele aujourd'hui"
            }
        }

        switch language {
        case .english:
            return "Frozen \(dateString(date, calendar: calendar))"
        case .norwegian:
            return "Fryst \(dateString(date, calendar: calendar))"
        case .spanish:
            return "Congelado el \(dateString(date, calendar: calendar))"
        case .french:
            return "Congele le \(dateString(date, calendar: calendar))"
        }
    }

    func bestQualitySummary(_ date: Date) -> String {
        switch language {
        case .english: return "Best quality by \(dateString(date))"
        case .norwegian: return "Best kvalitet innen \(dateString(date))"
        case .spanish: return "Mejor calidad antes de \(dateString(date))"
        case .french: return "Qualite optimale avant le \(dateString(date))"
        }
    }

    var noBestQualityDateSet: String {
        switch language {
        case .english: return "No best-quality date set"
        case .norwegian: return "Ingen best-kvalitetsdato satt"
        case .spanish: return "No hay fecha de mejor calidad"
        case .french: return "Aucune date de qualite optimale definie"
        }
    }

    func notesSummary(_ notes: String) -> String {
        switch language {
        case .english: return "Notes: \(notes)"
        case .norwegian: return "Notater: \(notes)"
        case .spanish: return "Notas: \(notes)"
        case .french: return "Notes : \(notes)"
        }
    }

    func presetSelected(_ category: FoodCategory, bestQualityAdded: Bool) -> String {
        switch language {
        case .english:
            return bestQualityAdded
                ? "\(foodCategory(category)) selected. Best-quality date added."
                : "\(foodCategory(category)) selected. No best-quality date added."
        case .norwegian:
            return bestQualityAdded
                ? "\(foodCategory(category)) valgt. Best-kvalitetsdato lagt til."
                : "\(foodCategory(category)) valgt. Ingen best-kvalitetsdato lagt til."
        case .spanish:
            return bestQualityAdded
                ? "\(foodCategory(category)) seleccionado. Se anadio una fecha de mejor calidad."
                : "\(foodCategory(category)) seleccionado. No se anadio fecha de mejor calidad."
        case .french:
            return bestQualityAdded
                ? "\(foodCategory(category)) selectionne. Une date de qualite optimale a ete ajoutee."
                : "\(foodCategory(category)) selectionne. Aucune date de qualite optimale n'a ete ajoutee."
        }
    }

    var presetDateAddedStatus: String {
        switch language {
        case .english: return "Best-quality date added from USDA guidance."
        case .norwegian: return "Best-kvalitetsdato lagt til fra USDA-veiledning."
        case .spanish: return "Fecha de mejor calidad anadida segun la guia del USDA."
        case .french: return "Date de qualite optimale ajoutee selon les recommandations USDA."
        }
    }

    var dateChangedStatus: String {
        switch language {
        case .english: return "Date changed"
        case .norwegian: return "Dato endret"
        case .spanish: return "Fecha cambiada"
        case .french: return "Date modifiee"
        }
    }

    var addContainerGuidance: String {
        switch language {
        case .english: return "Add a container. Tell us what you are freezing."
        case .norwegian: return "Legg til en beholder. Fortell hva du fryser."
        case .spanish: return "Anade un recipiente. Dinos que vas a congelar."
        case .french: return "Ajoutez un contenant. Dites-nous ce que vous congelez."
        }
    }

    var readyToWrite: String {
        switch language {
        case .english: return "Ready to write. Hold your iPhone near the tag."
        case .norwegian: return "Klar til skriving. Hold iPhone naer taggen."
        case .spanish: return "Listo para escribir. Acerca tu iPhone a la etiqueta."
        case .french: return "Pret a ecrire. Approchez votre iPhone de l'etiquette."
        }
    }

    var savedTagUpdated: String {
        switch language {
        case .english: return "Saved. Tag updated."
        case .norwegian: return "Lagret. Tagg oppdatert."
        case .spanish: return "Guardado. Etiqueta actualizada."
        case .french: return "Enregistre. Etiquette mise a jour."
        }
    }

    var tagUpdateFailed: String {
        switch language {
        case .english: return "The tag was not updated. Try holding your phone a little closer and keep it still."
        case .norwegian: return "Taggen ble ikke oppdatert. Prov a holde telefonen litt naermere og helt i ro."
        case .spanish: return "La etiqueta no se actualizo. Prueba a mantener el telefono un poco mas cerca y quieto."
        case .french: return "L'etiquette n'a pas ete mise a jour. Essayez de tenir votre telephone un peu plus pres et sans bouger."
        }
    }

    func successReplay(foodName: String, frozenDate: Date, bestBeforeDate: Date?) -> String {
        let frozenText = frozenSummary(frozenDate, referenceDate: Date.distantPast)

        if let bestBeforeDate {
            switch language {
            case .english:
                return "\(foodName). \(frozenText). Best quality by \(dateString(bestBeforeDate)). Tag updated successfully."
            case .norwegian:
                return "\(foodName). \(frozenText). Best kvalitet innen \(dateString(bestBeforeDate)). Taggen ble oppdatert."
            case .spanish:
                return "\(foodName). \(frozenText). Mejor calidad antes de \(dateString(bestBeforeDate)). La etiqueta se actualizo correctamente."
            case .french:
                return "\(foodName). \(frozenText). Qualite optimale avant le \(dateString(bestBeforeDate)). L'etiquette a ete mise a jour avec succes."
            }
        }

        switch language {
        case .english:
            return "\(foodName). \(frozenText). No best-quality date saved. Tag updated successfully."
        case .norwegian:
            return "\(foodName). \(frozenText). Ingen best-kvalitetsdato lagret. Taggen ble oppdatert."
        case .spanish:
            return "\(foodName). \(frozenText). No se guardo ninguna fecha de mejor calidad. La etiqueta se actualizo correctamente."
        case .french:
            return "\(foodName). \(frozenText). Aucune date de qualite optimale n'a ete enregistree. L'etiquette a ete mise a jour avec succes."
        }
    }

    func nfcError(_ error: NFCError) -> String {
        switch (language, error) {
        case (.english, .tagNotFound):
            return "No NFC tag detected. Please hold your iPhone near the tag and try again."
        case (.english, .readFailed):
            return "Failed to read the NFC tag. Please try again."
        case (.english, .writeFailed):
            return "Failed to write to the NFC tag. Please try again."
        case (.english, .tagRemoved):
            return "Tag was removed too quickly. Please hold your iPhone steady near the tag."
        case (.english, .multipleTagsDetected):
            return "Multiple tags detected. Please remove extra tags and try again."
        case (.english, .unsupportedTag):
            return "This tag type is not supported. Please use an NDEF-formatted tag."
        case (.english, .sessionTimeout):
            return "NFC session timed out. Please try again."
        case (.english, .sessionCancelled):
            return "NFC scanning was cancelled."
        case (.english, .invalidData):
            return "Invalid data on tag. The tag may be corrupted or empty."
        case (.english, .tagNotNDEF):
            return "Tag is not NDEF formatted. Please use an NDEF-compatible tag."
        case (.norwegian, .tagNotFound):
            return "Ingen NFC-tag funnet. Hold iPhone naer taggen og prov igjen."
        case (.norwegian, .readFailed):
            return "Kunne ikke lese NFC-taggen. Prov igjen."
        case (.norwegian, .writeFailed):
            return "Kunne ikke skrive til NFC-taggen. Prov igjen."
        case (.norwegian, .tagRemoved):
            return "Taggen ble fjernet for raskt. Hold iPhone rolig naer taggen."
        case (.norwegian, .multipleTagsDetected):
            return "Flere tagger ble oppdaget. Fjern ekstra tagger og prov igjen."
        case (.norwegian, .unsupportedTag):
            return "Denne taggtypen er ikke stottet. Bruk en NDEF-formatert tagg."
        case (.norwegian, .sessionTimeout):
            return "NFC-okten gikk ut pa tid. Prov igjen."
        case (.norwegian, .sessionCancelled):
            return "NFC-skanningen ble avbrutt."
        case (.norwegian, .invalidData):
            return "Ugyldige data pa taggen. Taggen kan vaere tom eller skadet."
        case (.norwegian, .tagNotNDEF):
            return "Taggen er ikke NDEF-formatert. Bruk en NDEF-kompatibel tagg."
        case (.spanish, .tagNotFound):
            return "No se detecto ninguna etiqueta NFC. Acerca tu iPhone a la etiqueta e intentalo de nuevo."
        case (.spanish, .readFailed):
            return "No se pudo leer la etiqueta NFC. Intentalo de nuevo."
        case (.spanish, .writeFailed):
            return "No se pudo escribir en la etiqueta NFC. Intentalo de nuevo."
        case (.spanish, .tagRemoved):
            return "La etiqueta se retiro demasiado pronto. Manten tu iPhone quieto cerca de la etiqueta."
        case (.spanish, .multipleTagsDetected):
            return "Se detectaron varias etiquetas. Retira las etiquetas adicionales e intentalo de nuevo."
        case (.spanish, .unsupportedTag):
            return "Este tipo de etiqueta no es compatible. Usa una etiqueta con formato NDEF."
        case (.spanish, .sessionTimeout):
            return "La sesion NFC ha caducado. Intentalo de nuevo."
        case (.spanish, .sessionCancelled):
            return "Se cancelo el escaneo NFC."
        case (.spanish, .invalidData):
            return "Hay datos no validos en la etiqueta. Puede estar vacia o danada."
        case (.spanish, .tagNotNDEF):
            return "La etiqueta no tiene formato NDEF. Usa una etiqueta compatible con NDEF."
        case (.french, .tagNotFound):
            return "Aucune etiquette NFC detectee. Approchez votre iPhone de l'etiquette et reessayez."
        case (.french, .readFailed):
            return "Impossible de lire l'etiquette NFC. Reessayez."
        case (.french, .writeFailed):
            return "Impossible d'ecrire sur l'etiquette NFC. Reessayez."
        case (.french, .tagRemoved):
            return "L'etiquette a ete retiree trop vite. Gardez votre iPhone immobile pres de l'etiquette."
        case (.french, .multipleTagsDetected):
            return "Plusieurs etiquettes ont ete detectees. Retirez les etiquettes supplementaires et reessayez."
        case (.french, .unsupportedTag):
            return "Ce type d'etiquette n'est pas pris en charge. Utilisez une etiquette au format NDEF."
        case (.french, .sessionTimeout):
            return "La session NFC a expire. Reessayez."
        case (.french, .sessionCancelled):
            return "Le scan NFC a ete annule."
        case (.french, .invalidData):
            return "Les donnees de l'etiquette sont invalides. L'etiquette est peut-etre vide ou endommagee."
        case (.french, .tagNotNDEF):
            return "L'etiquette n'est pas au format NDEF. Utilisez une etiquette compatible NDEF."
        }
    }
}
