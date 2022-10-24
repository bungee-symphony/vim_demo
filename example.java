package com.platoon.account.entity;

import static javax.persistence.TemporalType.TIMESTAMP;

// add text demo
java.io.Serializable
java.util.Date
java.util.UUID
javax.persistence.Column
javax.persistence.EntityListeners
javax.persistence.GeneratedValue
javax.persistence.Id
javax.persistence.MappedSuperclass
javax.persistence.Temporal
lombok.Getter
lombok.Setter
ort org.hibernate.annotations.GenericGenerator
ort org.springframework.data.annotation.CreatedBy
ort org.springframework.data.annotation.CreatedDate
ort org.springframework.data.annotation.LastModifiedBy
ort org.springframework.data.annotation.LastModifiedDate
ort org.springframework.data.jpa.domain.support.AuditingEntityListener

@Getter
@Setter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseModel implements Serializable {

    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(columnDefinition = "BINARY(16)")
    private UUID id;

    @Temporal(TIMESTAMP)
    @Column(nullable = false, updatable = false)
    @CreatedDate
    private Date createdAt;

    @Column(updatable = false, columnDefinition = "BINARY(16)")
    @CreatedBy
    private UUID createdBy;

    @Temporal(TIMESTAMP)
    @Column(nullable = false)
    @LastModifiedDate
    private Date updatedAt;

    @Column(columnDefinition = "BINARY(16)")
    @LastModifiedBy
    private UUID updatedBy;
}
