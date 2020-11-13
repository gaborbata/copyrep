/*
 * acme.component.ts
 *
 * Copyright (c) 2020 by Acme Company. All rights reserved.
 *
 * The copyright to the computer software herein is the property of
 * Acme Company. The software may be used and/or copied only
 * with the written permission of Acme Company or in accordance
 * with the terms and conditions stipulated in the agreement/contract
 * under which the software has been supplied.
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
