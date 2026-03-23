# Terraform und CI/CD

## Trouble

### 1. SSH Verbindung war nicht möglich, da Port 22 nicht freigeben war

- `ssh` Kommunikationen finden immer über den Port `22` statt
- Firewall blockiert standardmäßig alle Ports
- Wir mussten den Port 22 freischalten, sodass wir uns per ssh verbinden konnten

### 2. Wir haben gar keinen SSH Schlüssel auf der VM hinterlegt

- Voraussetzung wir haben ein Key-Pair
- Für heute haben wir uns über die AWS-Console einen Key-Pair erstellt (EC2 --> Sidebar --> Key-Pair --> Key-Pair erstellen --> Privater Schlüssel wurde zum Download bereitgestellt)

## Step by Step Guide für komplettes CI/CD Terraform deployment

1. Eine AWS-Sandbox erstellen mit ACCESS Key und Secret ACCESS KEY
2. Über AWS-Console anmelden
3. S3-Bucket manuell erstellen für den Terraform State, um den `.tfsate` anlegen
4. Erstellt ein neues repository in Github oder nutzt ein funktionierendes repository
5. Macht `git checkout main`
6. `git pull`
7. `git checkout -b feature/ci-cd-deployment-demo`
8. [main.tf](./main.tf) kopieren und bei euch in das Projekt speichern
9. Branch veröffentlichen
10. [`main.tf`](main.tf) s3-bucket anpassen, um den terraform state dort abzulegen

```bash
 backend "s3" {
    bucket = <euer-bucket-name> # <-- HIER HIN
    key    = "app/terraform.tfstate"
    region = "us-east-1"
  }
```

5. Key-Pair in suche eingeben --> Service auswählen --> Key Pair Feature auswählen --> Key-Pair erstellen (Private Schlüssel wird heruntergeladen)
   ![](./images/key_pair-service.png)
6. Key pair via Name in Terraform Datei austauschen

   ```yml
   resource "aws_instance" "demo" {
   ami                    = "ami-0b6c6ebed2801a5cb" # ubuntu
   instance_type          = "t2.micro"
   key_name               = <key-pair-name> # <---- HIER HIN
   vpc_security_group_ids = [aws_security_group.ssh.id]
   tags = {
    Name = "test-server-iac"
   }
   }
   ```

7. Commit mit message, die Änderungen pushen
8. [.github](./.github) Verzeichnis kopieren und in euer Projekt einfügen
9. Auf euer repo auf github.com gehen und dort unter Einstellungen --> Secrets --> Repository Secret anlegen
   --> Secrets müssen so heißen, wie sie in der `deploy.yaml` definiert sind:

- `AWS_ACCESS_KEY_ID` (mit euren werten von pluralsight)
- `AWS_SECRET_ACCESS_KEY` (mit euren werten von pluralsight)
  ![](./images/provide_secrets_github.png)

  ![](./images/secrets_github_2.png)

9. Pull request erstellen
10. Mergen von Pull request
11. Unter actions gucken, das die deploy pipeline durchläuft und über AWS Console verifizieren, dass die Resourcen erstellt wurden
