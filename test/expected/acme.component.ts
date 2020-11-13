/*
acme.component.ts

Copyright (c) 2020 Acme

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpService } from '../../http.service';
import { Observable, Subscription } from 'rxjs';
import { NotificationService } from '../../notification.service';
import { AcmeResponse } from './acme.type';
import { ChecklistItemStates } from '../../checklist-item/checklist-item.component';
import { TranslateService } from '@ngx-translate/core';
import { AlertMessages } from '../../alert/alert.model';

@Component({
  selector: 'app-acme',
  templateUrl: './acme.component.html'
})
export class AcmeComponent implements OnInit, OnDestroy {
  private subscriptions: Subscription;
  status = ChecklistItemStates.IDLE;
  mainTitle = '';

  constructor(private readonly http: HttpService,
              private readonly notificationService: NotificationService,
              private readonly translate: TranslateService) {}

  ngOnInit() {
    this.subscriptions = new Subscription();
    this.subscriptions.add(this.notificationService.acmeCheckTriggered$.subscribe(() => {
      this.status = ChecklistItemStates.LOADING;
      this.onCheckAcme().subscribe(
        result => this.notificationService.publishAcmeCheckResult(result),
        error => {
          this.notificationService.showErrorAlert(AlertMessages.COULD_NOT_CHECK_ACME);
          this.notificationService.publishAcmeCheckResult({successful: false, message: error.message});
        }
      );
    }));
    this.subscriptions.add(this.notificationService.acmeCheckCompleted$.subscribe(result => {
      this.status = result.successful ? ChecklistItemStates.COMPLETED : ChecklistItemStates.FAILED;
    }));
    this.subscriptions.add(this.translate.get('acme').subscribe(translation => {
      this.mainTitle = translation;
    }));
  }

  ngOnDestroy() {
    this.subscriptions.unsubscribe();
  }

  onCheckAcme(): Observable<AcmeResponse> {
    return this.http.getAcmeAvailability();
  }
}
