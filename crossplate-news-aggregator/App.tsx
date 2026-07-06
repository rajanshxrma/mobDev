import { Amplify } from 'aws-amplify';
import { Authenticator } from '@aws-amplify/ui-react-native';
import { StatusBar } from 'expo-status-bar';
import outputs from './amplify_outputs.json';
import RootNavigator from './src/navigation/RootNavigator';

Amplify.configure(outputs);

export default function App() {
  return (
    <Authenticator.Provider>
      <Authenticator>
        <RootNavigator />
        <StatusBar style="auto" />
      </Authenticator>
    </Authenticator.Provider>
  );
}
