import type {Ref} from 'vue';
import {actor} from '../services/runtime.js';

export interface MobileActor {
 id?: string;
 name?: string;
 account?: string;
 orgName?: string;
 userType?: string;
 identitySource?: string;
 authType?: string;
 phone?: string;
 email?: string;
}

export const mobileActor=actor as Ref<MobileActor|null>;
