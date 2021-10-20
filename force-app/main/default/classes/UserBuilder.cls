public class UserBuilder {
        private User record;

        public UserBuilder() {
            Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            this.record = new User(
                    Email = 'test.user@testel.com',
                    Username = 'test.userName@test.com.devsandbox',
                    Alias = 'tst.usr',
                	ProfileId = sysAdmin.Id,
                    LastName = 'LastName' + System.now(),
                    FirstName = 'FirstName' + System.now(),
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimezoneSidKey = 'Europe/Berlin',
                    EmailEncodingKey = 'UTF-8',
                    IsActive = true
            );
        }

        public UserBuilder withLastName(String lastName) {
            record.LastName = lastName;
            return this;
        }
        
        public UserBuilder withUsername(String username) {
            record.UserName = username;
            return this;
        }

        public UserBuilder withFirstName(String firstName) {
            record.FirstName = firstName;
            return this;
        }

        public UserBuilder withProfile(Id profileId) {
            record.ProfileId = profileId;
            return this;
        }

        public UserBuilder withEmail(String email) {
            record.Email = email;
            return this;
        }

        public User getRecord() {
            return record;
        }

        public User createRecord() {
            if (record.Id == null) {
                insert record;
            } else {
                update record;
            }
            return record;
        }
    }